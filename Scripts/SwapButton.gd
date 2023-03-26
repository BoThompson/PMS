extends Button

var held
var time_held
@export var swap_timer : float
# Called when the node enters the scene tree for the first time.
func _ready():
	time_held = 0
	pass # Replace with function body.

func on_swap_pressed():
	held = true
	time_held = 0
	
	
func on_swap_released():
	held = false
	time_held = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Fill.scale = Vector2(minf(1, time_held / swap_timer), 1)
	if held:
		time_held += delta
		if time_held >= swap_timer:
			GameManager.reset_player_field()
			held = false
	pass
