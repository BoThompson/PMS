extends Node


var combatants = {}

var playerField : EnergyField
var oppField : EnergyField

var playerResourceBoard : ResourceBoard
var oppResourceBoard : ResourceBoard


signal playerResourcesChanged(resource_list)
signal oppResourcesChanged(resource_list)
signal playerReadyChanged(value)

signal player_active_time_updated(value, action_selected)
signal opp_active_timer_up
var resources
var selected_actions = [null, null]

const characters_data = preload("res://Data/characters.tres").data

var actions = {
	#"NAME": {
	#	"description":"DESCRIPTION IN BBCODE FORMAT"
	#	"cost":[ATTACK, DEFENSE, FOCUS, AURA, YIN, YANG, EARTH, FIRE, METAL, WATER, WOOD]
	#	"target": 0 - Self, 1 - Single, 2 - AOE, 3 - All Enemies, 4 - ALL
	"fireball": {
		"description":"A blast of flame dealing [stat name=damage factor=0.5 base=5] fire damage to one target.",
		"cost":[0,0,0,5,0,3,0,0,0],
		"target":1,
		"function":"fireball"
		
	},
	"punch": {
		"description":"A blast of flame dealing [stat name=damage factor=0.5 base=5] fire damage to one target.",
		"cost":[3,0,0,0,0,0,0,0,0],
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
	reset_resources()

func register_resource_board(board, is_player):
	if is_player:
		playerResourceBoard = board
		playerResourcesChanged.connect(board.on_resources_changed)
	else:
		oppResourceBoard = board
		oppResourcesChanged.connect(board.on_resources_changed)
func reset_resources():
	resources = [[],[]]
	resources[0].resize(6)
	resources[1].resize(6)
	resources[0].fill(0)
	resources[1].fill(0)

func reset_player_field():
	playerField.reset()
	
func add_resource(resource, amt, player):
	if player:
		resources[0][resource] += amt
		playerResourcesChanged.emit(resources[0])
	else:
		resources[1][resource] += amt
		oppResourcesChanged.emit(resources[1])

func select_action(is_player, action) -> bool:
	if is_player:
		if test_ready <= 0:
			initiate_action(0, action)
		else:
			selected_actions[0] = action
		return true
	else:
		selected_actions[1] = action
		return true

const ready_length = 8
var test_ready = ready_length

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	test_ready -= delta
	playerReadyChanged.emit((ready_length - test_ready) / ready_length)
	

func _on_player_ready_changed():
	if selected_actions[0] != null:
		initiate_action(0, selected_actions[0])

func initiate_action(id, action):
	if id==0:
		combatants[id].initiate_action(action)

func register_combatant(combatant, id):
		combatants[id] = combatant

func default_action(id, action):
	if id == 0:
		if selected_actions[0] != null:
			return false
		if test_ready <= 0:
			initiate_action(0, action)
		else:
			selected_actions[0] = action
		return true
	else:
		selected_actions[1] = action
		return true
