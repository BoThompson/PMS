extends Control

signal mouse_moved(v)
var last_mouse
var clothing_sounds = [
	preload("res://Sounds/TITLE SCREEN/foley_cloth_light_fast_movement_01.wav"),
	preload("res://Sounds/TITLE SCREEN/foley_cloth_light_fast_movement_02.wav"),
	preload("res://Sounds/TITLE SCREEN/foley_cloth_light_fast_movement_04.wav")
]

# Called when the node enters the scene tree for the first time.
func _ready():
	last_mouse = get_viewport().get_mouse_position()
	%"Continue Button".disabled = true
	%"Options Button".disabled = true
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


func _on_start_button_pressed():
	GameManager.transition_scene("res://Scenes/character select.tscn")
	pass # Replace with function body.


func _on_continue_button_pressed():
	print("NOT POSSIBLE YET")
	pass # Replace with function body.


func _on_options_button_pressed():
	print("NOT POSSIBLE YET")
	pass # Replace with function body.


func _on_clothing_finished():
	var flutter = randi_range(0, 2)
	$Clothing.stream = clothing_sounds[flutter]
	$Clothing.play()
	pass # Replace with function body.
