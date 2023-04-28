class_name Destination
extends Sprite2D

@export var path_nodes : Array[NodePath]
var paths : Array[Path]
# Called when the node enters the scene tree for the first time.
func _ready():
	var converted_paths : Array[Path]
	for p in path_nodes:
		converted_paths.append(get_node(p))
	paths = converted_paths
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
