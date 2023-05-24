extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var color_tween = create_tween()
	color_tween.set_parallel(false)
	color_tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	color_tween.tween_interval(.2)
	color_tween.tween_property(self, "modulate", Color(1,1,1,0), 0.2)
	color_tween.play()
	var pos_tween = create_tween()
	pos_tween.set_parallel(false)
	pos_tween.tween_property(self, "position", position - Vector2(0,20), 0.6)
	pos_tween.tween_callback(queue_free)
	pos_tween.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass
