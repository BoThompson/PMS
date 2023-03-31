class_name ResourceBoard
extends TextureRect



@export var signal_name : String
# Called when the node enters the scene tree for the first time.
func _ready():
	if(signal_name in GameManager):
		GameManager.get(signal_name).connect(_on_resources_changed)
	else:
		print_debug("Signal " + signal_name + " not found.")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_resources_changed(resources):
	$Attack.text = str(resources[0])
	$Defense.text =  str(resources[1])
	$Focus.text = str(resources[2])
	$Qi.text = str(resources[3])
	$Yin.text = str(resources[4])
	$Yang.text = str(resources[5])
