extends Node2D


const action_button_prefab = preload("res://Prefabs/action_button.tscn")
const basic_action_button_prefab = preload("res://Prefabs/basic_action_button.tscn")
var action_buttons = [null]

const combatant_prefab = preload("res://Prefabs/combatant.tscn")
var playerField : EnergyField
var oppField : EnergyField

var playerResourceBoard : ResourceBoard
var oppResourceBoard : ResourceBoard


var combatants = {}
var selected_actions = [null, null]
const player_hud = preload("res://Prefabs/player_hud.tscn")
const enemy_hud = preload("res://Prefabs/enemy_hud.tscn")


func fireball(targets):
	pass
	
var actions = {
	#"NAME": {
	#	"description":"DESCRIPTION IN BBCODE FORMAT"
	#	"cost":[ANY, ATTACK, DEFENSE, FOCUS, AURA, YIN, YANG, EARTH, FIRE, METAL, WATER, WOOD]
	#	"target": 0 - Self, 1 - Single, 2 - AOE, 3 - All Enemies, 4 - ALL
	"fireball": {
		"description":"A blast of flame dealing [stat name=damage factor=0.5 base=5] fire damage to one target.",
		"cost":[0,0,0,0,5,0,3,0,0,0],
		"target":1,
		"function":"fireball"
		
	},
	"punch": {
		"description":"A blast of flame dealing [stat name=damage factor=0.5 base=5] fire damage to one target.",
		"cost":[3,0,0,0,0,0,0,0,0,0],
		"target":1,
		"function":"punch"
		
	}
}


func add_action_button(action):
	var name = action.name
	var primary = action.basic
	if primary:
		if action_buttons[0] != null:
			action_buttons[0].queue_free()
		action_buttons[0] = basic_action_button_prefab.instantiate()
		$HUD.add_child(action_buttons[0])
		action_buttons[0].position = Vector2(15, 285)
		action_buttons[0].setup(name)
	elif len(action_buttons) >= 9:
		print("ERROR: Attempted to add too many action buttons.")
	else:
		var idx = len(action_buttons)
		action_buttons.append(action_button_prefab.instantiate())
		$HUD.add_child(action_buttons[idx])
		action_buttons[idx].position = Vector2(15 + 130 * (idx % 2), 295 + 58 * int(idx/2))
		action_buttons[idx].setup(name)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_combatant(combatant_name, is_player, on_left):
	var combatant = combatant_prefab.instantiate()
	var data = GameManager.characters_data[combatant_name]
	var cs = CharStats.load(data)
	combatant.setup(cs, is_player, on_left)
	if !on_left:
		combatant.position.x = 960 - combatant.position.x
	register_combatant(combatant, on_left)
	get_tree().root.add_child(combatant)

func get_opponent(id) -> Combatant:
	if id == 0:
		return combatants[1]
	else:
		return combatants[0]
		
func _on_ready_changed(id : int, value : float):
	if value >= 1 and selected_actions[id] != null:
		queue_action(selected_actions[id], get_opponent(id))

func queue_action(id, action):
	var opp = get_opponent(id)
	combatants[0].queue_action(action, get_opponent(id))

func register_combatant(combatant : Combatant, on_left : bool):
	combatants[combatant.id] = combatant
	combatant.ready_time_changed.connect(_on_ready_changed)
	var hud
	if on_left:
		hud = player_hud.instantiate()
	else:
		hud = enemy_hud.instantiate()
	#setup the buttons
	if combatant.is_player():
		for action in combatant.actions:
			var button = add_action_button(action)
	hud.setup(combatant, on_left)
	get_tree().root.add_child(hud)
	if combatant.is_player():
		hud.position = Vector2(10,10)
	else:
		hud.position = Vector2(780, 10)

func spawn_action_button(action):
	var button
	if len(action_buttons) == 0:
		button = basic_action_button_prefab.instantiate()
	else:
		button = action_button_prefab.instantiate()
		
func default_action(id, action):
	if selected_actions[id] != null:
		return false
	select_action(id, action)
	return true

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.battle = self
	selected_actions = []
	selected_actions.resize(2)
	selected_actions.fill(null)


func reset_player_field():
	playerField.reset()
	
func add_resource(resource, amt, id):
	combatants[id].add_resource(resource, amt)

func select_action(id, action) -> bool:
	if combatants[id].ready_time_remaining <= 0:
		queue_action(id, action)
	else:
		combatants[id].set_action_label(action)
		selected_actions[id] = action
	return true

