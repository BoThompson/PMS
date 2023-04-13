class_name ResourceBoard
extends TextureRect


const offset = Vector2(17, 86)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setup(combatant : Combatant):
	combatant.resources_changed.connect(_on_resources_changed)
	position = offset
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_resources_changed(resources):
	$Attack.text = str(resources[0])
	$Defense.text =  str(resources[1])
	$Focus.text = str(resources[2])
	$Aura.text = str(resources[3])
	$Yin.text = str(resources[4])
	$Yang.text = str(resources[5])
