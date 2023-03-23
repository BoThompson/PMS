class_name ResourceBoard
extends Panel


@export var player : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.register_resource_board(self, player)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_resources_changed(resources):
	$Attack.text = str(resources[0])
	$Defense.text =  str(resources[1])
	$Focus.text = str(resources[2])
	$Qi.text = str(resources[3])
	$Yin.text = str(resources[4])
	$Yang.text = str(resources[5])
