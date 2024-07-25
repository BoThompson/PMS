class_name Orb extends Control

####################################################################################################	
####################################           Members           ###################################
####################################################################################################

#############################################   Enums   ############################################
enum OrbState {RISING, SWAPPING, SELECTABLE, SELECTED, ACTIVATED}
enum OrbType {WILDCARD, ATTACK, DEFENSE, FOCUS, AURA, YIN, YANG, MONEY, XP, EARTH, WATER, FIRE, METAL, WOOD, BLOOD, FURY }
enum OrbLit {UNLIT, LIT}
########################################   Enum Identifiers   ######################################
const OrbTypeNames = {
	"wildcard":OrbType.WILDCARD, 
	"attack":OrbType.ATTACK, 
	"defense":OrbType.DEFENSE, 
	"focus":OrbType.FOCUS, 
	"aura":OrbType.AURA, 
	"yin":OrbType.YIN, 
	"yang":OrbType.YANG, 
	"money":OrbType.MONEY, 
	"xp":OrbType.XP, 
	"earth":OrbType.EARTH, 
	"water":OrbType.WATER, 
	"fire":OrbType.FIRE, 
	"metal":OrbType.METAL, 
	"wood":OrbType.WOOD, 
	"blood":OrbType.BLOOD, 
	"fury":OrbType.FURY
}

#############################################   Exports   ##########################################
@export var state : OrbState
@export var lit : bool : set=_on_change_lit

###########################################   Internals   ##########################################
var type : OrbType : set=_on_change_type
var field : EnergyField
var tween : Tween
var coordinate : Vector2i
var deployed = true
var marked : bool = false
@onready var anim_player : AnimationPlayer = $AnimationPlayer
####################################################################################################	
####################################          Resources          ###################################
####################################################################################################

var animations = {
	OrbType.ATTACK 	: {
		"idle": "Attack Idle",
		"marked": "Attack Marked",
	},
	OrbType.DEFENSE : {
		"idle": "Defense Idle",
		"marked": "Defense Marked",
	},
	OrbType.FOCUS 	: {
		"idle": "Focus Idle",
		"marked": "Focus Marked",
	},
	OrbType.AURA 	: {
		"idle": "Aura Idle",
		"marked": "Aura Marked",
	},
	OrbType.YIN 	: {
		"idle": "Yin Idle",
		"marked": "Yin Marked",
	},
	OrbType.YANG 	: {
		"idle": "Yang Idle",
		"marked": "Yang Marked",
	},
	OrbType.MONEY	: {
		"idle": "Money Idle",
		"marked": "Money Marked",
	},
	OrbType.XP	: {
		"idle": "XP Idle",
		"marked": "XP Marked",
	}
}

####################################################################################################	
################################          Getters / Setters          ###############################
####################################################################################################

func _on_change_type(value : OrbType):
	if value != OrbType.WILDCARD:
		anim_player.play(animations[value].idle)
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
	if marked:
		return
	anim_player.play(animations[type].marked)
	$Marker.visible = true
	marked = true

func unmark():
	if !marked:
		return
	anim_player.play(animations[type].idle)
	$Marker.visible = true
	marked = false
	
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

	
func shuffle(weights : Array[int]):
	#var max = weights.reduce(func(accum, n): return accum + n, 0)
	#var num = randi_range(0, max)
	#var n = num
	#type = OrbType.WILDCARD
	#for i in range(len(weights)):
		#if num < weights[i]:
			#type = (i + 1) as OrbType # Omit the wildcard
			#break
		#else:
			#num -= weights[i]
	#if type == OrbType.WILDCARD:
		#print("ERROR: Shuffle failed to determine a type")
		#print("Num: " + str(n))
		#print("Weights: " + str(weights))
	type = randi_range(1,7)

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
