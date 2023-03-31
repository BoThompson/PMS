extends "res://Scripts/EnergyBar.gd"


func _on_value_changed(value):
	$Fill.material.set_shader_parameter("cutoff", value)
	$Fill.material.set_shader_parameter("direction", bar_direction)
	if value >= 1:
		$Alert.visible = true
	else:
		$Alert.visible = false
