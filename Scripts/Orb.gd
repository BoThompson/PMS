class_name Orb
extends Control

####################################################################################################	
####################################           Members           ###################################
####################################################################################################

#############################################   Enums   ############################################
enum OrbState {RISING, SWAPPING, SELECTABLE, SELECTED, ACTIVATED}
enum OrbType {WILDCARD, ATTACK, DEFENSE, FOCUS, AURA, YIN, YANG, EARTH, WATER, FIRE, METAL, WOOD, BLOOD, FURY}
enum OrbLit {UNLIT, LIT}

#############################################   Exports   ##########################################
@export var state : OrbState
@export var lit : bool : set=_on_change_lit

###########################################   Internals   ##########################################
var type : OrbType : set=_on_change_type
var field : EnergyField
var tween : Tween
var coordinate : Vector2i
var deployed = true
####################################################################################################	
####################################          Resources          ###################################
####################################################################################################

var animations = {
	OrbType.ATTACK 	: {
		"idle": "Attack Idle",	
	},
	OrbType.DEFENSE : {
		"idle": "Defense Idle",	
	},
	OrbType.FOCUS 	: {
		"idle": "Focus Idle",	
	},
	OrbType.AURA 	: {
		"idle": "Aura Idle",	
	},
	OrbType.YIN 	: {
		"idle": "Yin Idle",	
	},
	OrbType.YANG 	: {
		"idle": "Yang Idle",	
	},
}

####################################################################################################	
################################          Getters / Setters          ###############################
####################################################################################################

func _on_change_type(value : OrbType):
	$AnimationPlayer.play(animations[value].idle)
	type = value
	
func _on_change_lit(value):
	$Highlight.visible = value
	lit = value

####################################################################################################	
################################           Default Methods           ###############################
####################################################################################################

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):	
	pass
	

####################################################################################################	
##################################          Helper Methods         #################################
####################################################################################################
func mark():
	$Marker.visible = true

func unmark():
	$Marker.visible = true
	
func select():
	transition(OrbState.SELECTED)

func deselect():
	transition(OrbState.SELECTABLE)
	
func toggle_select():
	if state == OrbState.SELECTABLE:
		transition(OrbState.SELECTED)
	else:
		transition(OrbState.SELECTABLE)

####################################################################################################	
##################################          State Methods          #################################
####################################################################################################
	
func swap(coord):
	coordinate = coord
	transition(OrbState.SWAPPING)
	
func activate():
	transition(OrbState.ACTIVATED)

func rise(offset):
	coordinate.y -= offset
	transition(OrbState.RISING)

	
func shuffle():
	type =randi_range(1, 6) as OrbType

####################################################################################################	
#############################          Tween Resolution Methods         ############################
####################################################################################################

func _on_swap_complete():
	field.remove_active_orb(self)
	transition(OrbState.SELECTABLE)

func _on_activate_complete():
	field.remove_active_orb(self)
	exit_state(OrbState.ACTIVATED)

func _on_fall_complete():
	field.remove_active_orb(self)
	transition(OrbState.SELECTABLE)
	
####################################################################################################	
#############################           State Machine Methods           ############################
####################################################################################################

func enter_state(new_state):
	state = new_state
	match(state):
		OrbState.RISING:
			tween = create_tween()
			var final_position = 50*Vector2(coordinate.x,coordinate.y) + (Vector2.ONE * 36)
			if(deployed):
				modulate = Color(1,1,1,0)
				tween.tween_property(self, "modulate", Color(1,1,1,1), .2 * -(final_position.y - position.y) / 50)
			deployed = false
			tween.tween_property(self, "position", final_position, .15 * -(final_position.y - position.y) / 50).set_ease(Tween.EASE_IN)
			tween.tween_callback(_on_fall_complete)
			field.add_active_orb(self)
		OrbState.SWAPPING:
			tween = create_tween()
			var final_position = 50*Vector2(coordinate.x,coordinate.y) + (Vector2.ONE * 36)
			tween.tween_property(self, "position", final_position, .25).set_ease(Tween.EASE_IN_OUT)
			tween.tween_callback(_on_swap_complete)
			field.add_active_orb(self)
		OrbState.SELECTABLE:
			lit = OrbLit.UNLIT
		OrbState.SELECTED:
			lit = OrbLit.LIT
		OrbState.ACTIVATED:
			tween = create_tween()
			tween.tween_property(self, "modulate", Color(0,0,0,0), .25).set_ease(Tween.EASE_IN_OUT)
			tween.tween_callback(_on_activate_complete)
			field.add_active_orb(self)
			
	
func exit_state(old_state):
	match(old_state):
		OrbState.RISING:
			pass
		OrbState.SWAPPING:
			pass
		OrbState.SELECTABLE:
			pass
		OrbState.SELECTED:
			pass
		OrbState.ACTIVATED:
			field.clear_orb(coordinate)
			field.add_resource(type, 1)
			queue_free()

func transition(forced_state):
	exit_state(state)
	if forced_state != null:
		enter_state(forced_state)
	else:
		match(state):
			OrbState.RISING:
				enter_state(OrbState.SELECTABLE)
			OrbState.SWAPPING:
				pass
			OrbState.SELECTABLE:
				pass
			OrbState.SELECTED:
				pass
			OrbState.ACTIVATED:
				pass
