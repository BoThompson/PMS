extends Sprite2D

@export var offset_height : float
var move_tween : Tween
# Called when the node enters the scene tree for the first time.
func _ready():
	move_tween = create_tween()

	move_tween.tween_interval(randf())
	move_tween = move_tween.chain()
	move_tween.set_loops(-1)
	move_tween.tween_property(self, "position", position + Vector2(0, offset_height), 1.5 )
	move_tween.tween_property(self, "position", position + Vector2(0, -offset_height), 1.5 )
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
