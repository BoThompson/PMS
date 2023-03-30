extends Control

var plates = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func update_character(data):
	$"Character Select Panel".update_character(data)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
