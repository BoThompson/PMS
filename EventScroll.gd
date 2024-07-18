extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func setup(data):
	return

func unroll():
	var tween = create_tween()
	$AudioStreamPlayer2D.play()
	$Animator.play("slide")
	$Animator.advance(.3)
	tween.tween_property(self, "position", Vector2.ZERO, .5)
	tween.tween_property($Contents, "modulate:a", 1, .25)
	tween.play()


func roll():
	var tween = create_tween()
	$AudioStreamPlayer2D.play()
	$Animator.play("slide")
	tween.tween_property($Contents, "modulate:a", 0, .25)
	tween.tween_property(self, "position", Vector2(960,0), 1)
	tween.chain().tween_callback(queue_free)
	tween.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
