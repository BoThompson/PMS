extends Node


var combatants = {}


var playerField : EnergyField
var oppField : EnergyField

var playerResourceBoard : ResourceBoard
var oppResourceBoard : ResourceBoard

var selected_actions = [null, null]

const characters_data = preload("res://Data/characters.tres").data

const character_hud = preload("res://Prefabs/character_hud.tscn")

const combatant_prefab = preload("res://Prefabs/combatant.tscn")

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

func fireball(targets):
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready():
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
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

func register_combatant(combatant : Combatant):
	combatants[combatant.id] = combatant
	combatant.ready_time_changed.connect(_on_ready_changed)
	var hud = character_hud.instantiate()
	hud.setup(combatant)
	get_tree().root.add_child(hud)
	if combatant.is_player():
		hud.position = Vector2(10,10)
	else:
		hud.position = Vector2(780, 10)
	combatant.ready_time_changed.connect(hud._on_ready_time_changed)
	combatant.life_changed.connect(hud._on_life_changed)

func default_action(id, action):
	if selected_actions[id] != null:
		return false
	select_action(id, action)
	return true

func add_combatant(combatant_name, is_player, on_left):
	var combatant = combatant_prefab.instantiate()
	combatant.setup(CharStats.load(characters_data[combatant_name]), is_player, on_left)
	
