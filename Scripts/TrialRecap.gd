extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_okay_button_pressed():
	#TODO: SAVE PROGRESS FROM RUN
	GameManager.transition_scene("res://Scenes/title_screen.tscn")
	pass # Replace with function body.
