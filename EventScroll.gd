extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func unroll():
	var tween = create_tween()
	$Animator.play("slide")
	$Animator.advance(.3)
	tween.tween_property(self, "position", Vector2.ZERO, .5)
	tween.play()


func roll():
	var tween = create_tween()
	$Animator.play("slide")
	tween.tween_property(self, "position", Vector2(960,0), 1)
	tween.chain().tween_callback(queue_free)
	tween.play()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
