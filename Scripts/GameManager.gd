extends Node

var playerBoard : MatchBoard
var oppBoard : MatchBoard

var playerResourceBoard : ResourceBoard
var oppResourceBoard : ResourceBoard


signal playerResourcesChanged(resource_list)
signal oppResourcesChanged(resource_list)

signal player_active_time_updated(value, action_selected)
signal opp_active_timer_up
var resources
var selected_actions
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

func reset_player_board():
	playerBoard.reset()
	
func add_resource(resource, amt, player):
	if player:
		resources[0][resource] += amt
		playerResourcesChanged.emit(resources[0])
	else:
		resources[1][resource] += amt
		oppResourcesChanged.emit(resources[1])

func select_action(is_player, action) -> bool:
	if is_player:
		selected_actions[0] = action
		return true
	else:
		selected_actions[1] = action
		return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		for orb in playerBoard.get_children():
			var c = orb.coordinate
			var oo = playerBoard.orbs[c.x][c.y]
			if oo != null:
				var oc = oo.coordinate
				if c != oc:
					print("Orb [" + str(c.x) + ", " + str(c.y) + "] vs [" + str(oc.x) + ", " + str(oc.y) + "]")
			else:
				print("Orb [" + str(c.x) + ", " + str(c.y) + "] vs [NULL]")
	pass
