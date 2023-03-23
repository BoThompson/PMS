class_name Orb
extends Control

####################################################################################################	
####################################           Members           ###################################
####################################################################################################

#############################################   Enums   ############################################
enum OrbState {FALLING, SWAPPING, SELECTABLE, SELECTED, ACTIVATED}
enum OrbType {ATTACK, DEFENSE, PREPARE, QI, YIN, YANG}
enum OrbLit {UNLIT, LIT}

#############################################   Exports   ##########################################
@export var state : OrbState
@export var lit : OrbLit : set=_on_change_lit

###########################################   Internals   ##########################################
var type : OrbType : set=_on_change_type
var board : MatchBoard
var tween : Tween
var coordinate : Vector2i
var deployed = true
####################################################################################################	
####################################          Resources          ###################################
####################################################################################################

var symbol_sprites = {
	OrbType.ATTACK + 1000 * OrbLit.UNLIT : preload("res://Sprites/Unlit Attack.png"),
	OrbType.DEFENSE + 1000 *  OrbLit.UNLIT : preload("res://Sprites/Unlit Defense.png"),
	OrbType.PREPARE + 1000 *  OrbLit.UNLIT : preload("res://Sprites/Unlit Prepare.png"),
	OrbType.QI + 1000 *  OrbLit.UNLIT : preload("res://Sprites/Unlit Qi.png"),
	OrbType.YIN + 1000 *  OrbLit.UNLIT : preload("res://Sprites/Unlit Yin.png"),
	OrbType.YANG + 1000 *  OrbLit.UNLIT : preload("res://Sprites/Unlit Yang.png"),
	OrbType.ATTACK + 1000 * OrbLit.LIT : preload("res://Sprites/Lit Attack.png"),
	OrbType.DEFENSE + 1000 *  OrbLit.LIT : preload("res://Sprites/Lit Defense.png"),
	OrbType.PREPARE + 1000 *  OrbLit.LIT : preload("res://Sprites/Lit Prepare.png"),
	OrbType.QI + 1000 *  OrbLit.LIT : preload("res://Sprites/Lit Qi.png"),
	OrbType.YIN + 1000 *  OrbLit.LIT : preload("res://Sprites/Lit Yin.png"),
	OrbType.YANG + 1000 *  OrbLit.LIT : preload("res://Sprites/Lit Yang.png"),
}

var orb_sprites = {
	OrbLit.UNLIT : preload("res://Sprites/Unlit Tile.png"),
	OrbLit.LIT : preload("res://Sprites/Lit Tile.png")
}

####################################################################################################	
################################          Getters / Setters          ###############################
####################################################################################################

func _on_change_type(value : OrbType):
	$Symbol.texture = symbol_sprites[lit * 1000 + value]
	type = value
	
func _on_change_lit(value : OrbLit):
	$Background.texture = orb_sprites[value]
	$Symbol.texture = symbol_sprites[value * 1000 + type]
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

func fall(offset):
	coordinate.y -= offset
	name = "Orb [" + str(coordinate.x) + ", " + str(coordinate.y) + "]"
	transition(OrbState.FALLING)

	
func shuffle():
	type =randi_range(0, OrbType.size() - 1) as OrbType

####################################################################################################	
#############################          Tween Resolution Methods         ############################
####################################################################################################

func _on_swap_complete():
	board.remove_active_orb(self)
	transition(OrbState.SELECTABLE)

func _on_activate_complete():
	board.remove_active_orb(self)
	exit_state(OrbState.ACTIVATED)

func _on_fall_complete():
	board.remove_active_orb(self)
	transition(OrbState.SELECTABLE)
	
####################################################################################################	
#############################           State Machine Methods           ############################
####################################################################################################

func enter_state(new_state):
	state = new_state
	match(state):
		OrbState.FALLING:
			tween = create_tween()
			var final_position = 64*Vector2(coordinate.x,4-coordinate.y)
			if(deployed):
				modulate = Color(1,1,1,0)
				tween.tween_property(self, "modulate", Color(1,1,1,1), .2 * (final_position.y - position.y) / 64)
			deployed = false
			tween.tween_property(self, "position", final_position, .2 * (final_position.y - position.y) / 64).set_ease(Tween.EASE_IN)
			tween.tween_callback(_on_fall_complete)
			board.add_active_orb(self)
		OrbState.SWAPPING:
			tween = create_tween()
			var final_position = 64*Vector2(coordinate.x,4-coordinate.y)
			tween.tween_property(self, "position", final_position, .25).set_ease(Tween.EASE_IN_OUT)
			tween.tween_callback(_on_swap_complete)
			board.add_active_orb(self)
		OrbState.SELECTABLE:
			lit = OrbLit.UNLIT
		OrbState.SELECTED:
			lit = OrbLit.LIT
		OrbState.ACTIVATED:
			tween = create_tween()
			tween.tween_property(self, "modulate", Color(0,0,0,0), .25).set_ease(Tween.EASE_IN_OUT)
			tween.tween_callback(_on_activate_complete)
			board.add_active_orb(self)
			
	
func exit_state(old_state):
	match(old_state):
		OrbState.FALLING:
			pass
		OrbState.SWAPPING:
			pass
		OrbState.SELECTABLE:
			pass
		OrbState.SELECTED:
			pass
		OrbState.ACTIVATED:
			board.clear_orb(coordinate)
			board.add_resource(type, 1)
			queue_free()

func transition(forced_state):
	exit_state(state)
	if forced_state != null:
		enter_state(forced_state)
	else:
		match(state):
			OrbState.FALLING:
				enter_state(OrbState.SELECTABLE)
			OrbState.SWAPPING:
				pass
			OrbState.SELECTABLE:
				pass
			OrbState.SELECTED:
				pass
			OrbState.ACTIVATED:
				pass
