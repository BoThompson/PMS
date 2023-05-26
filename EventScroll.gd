extends Control

var fully_unrolled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	unroll(false)

func unroll(full : bool):
	var tween = create_tween()
	if full:
		tween.tween_property(self, "position", Vector2.ZERO, 1)
		fully_unrolled = true
	else:
		tween.tween_property(self, "position", Vector2(480,0), 1)
	tween.play()


func roll():
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(960,0), 1)
	tween.play()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
