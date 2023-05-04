extends "res://Scripts/EnergyBar.gd"

var last_value = 0
var has_alert : bool

func _ready():
	$Fill.set_material($Fill.get_material().duplicate(true))
	
func initialize_bar(value):
	$Fill.material.set_shader_parameter("cutoff", value)
	$Fill.material.set_shader_parameter("direction", bar_direction)
	
func update_bar(value):
	$Fill.material.set_shader_parameter("cutoff", value)
	$Fill.material.set_shader_parameter("direction", bar_direction)
	
	if value < 1:
		$Alert.visible = false
	elif last_value < 1:
			var tween = create_tween()
			tween.tween_property($Fill, "material:shader_parameter/tint", Vector3(1,1,1), .1)
			if has_alert:
				tween.tween_property($Alert, "visible", true, .01)
			tween.tween_property($Fill, "material:shader_parameter/tint", Vector3(0,0,0), .1)
			tween.play()
	last_value = value
		
