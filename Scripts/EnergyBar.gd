extends Node2D


enum BAR_DIRECTION {left, right, up, down}
@export var signal_name : String
@export var bar_direction : BAR_DIRECTION
# Called when the node enters the scene tree for the first time.
func _ready():
	if(signal_name in GameManager):
		GameManager.get(signal_name).connect(_on_value_changed)
	else:
		print_debug("Signal " + signal_name + " not found.")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_value_changed(value):
	$Fill.material.set_shader_parameter("cutoff", value)
	$Fill.material.set_shader_parameter("direction", bar_direction)
