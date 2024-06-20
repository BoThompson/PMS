extends Node2D

var start_position : Vector2
@export var max_offset : Vector2
# Called when the node enters the scene tree for the first time.
func _ready():
	start_position = global_position
	var mp =  get_viewport().get_mouse_position()
	var ss = DisplayServer.screen_get_size()
	var offset = -Vector2(mp.x / ss.x, mp.y / ss.y) * 2 + Vector2.ONE
	offset_position(offset)
	get_node("/root/Title Screen").register_element(self)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_mouse_moved(v):
	var ss = DisplayServer.screen_get_size()
	var offset = -Vector2(v.x / ss.x, v.y / ss.y) * 2 + Vector2.ONE
	offset_position(offset)
	
func offset_position(v):
	v.x = max_offset.x * v.x
	v.y = max_offset.y * v.y
	global_position = start_position + v
