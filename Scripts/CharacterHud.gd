extends Control

var resource_board : ResourceBoard
var resource_board_prefab = preload("res://Prefabs/resource_board.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_ready_time_changed(_id, value):
	$"Ready Bar".update_value(value)
	
func _on_life_changed(_id, value):
	$"Character Plate/Life Bar".update_value(value)		

func setup(combatant: Combatant):
	$"Character Plate/Portrait".texture = load("res://Sprites/Portraits/" + combatant.stats.data["assets"]["portrait_image"])
	$"Character Plate/Portrait".texture = load("res://Sprites/Titles/" + combatant.stats.data["assets"]["title_image"])
	$"Ready Bar".update_value(combatant.stats.health / combatant.stats.max_health)
	#TODO - Put Affects here
	if combatant.is_player():
		resource_board = resource_board_prefab.instantiate()
		add_child(resource_board)
		resource_board.setup(combatant)
