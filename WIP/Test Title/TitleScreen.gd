extends Control

signal mouse_moved(v)
var last_mouse
# Called when the node enters the scene tree for the first time.
func _ready():
	last_mouse = get_viewport().get_mouse_position()
	pass # Replace with function body.


func register_element(element):
	mouse_moved.connect(element.on_mouse_moved)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	if mouse_pos != last_mouse:
		mouse_moved.emit(mouse_pos)
	last_mouse = mouse_pos
	pass
