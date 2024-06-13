class_name ActiveTimer extends ProgressBar

@onready var action_label : Label = $Action
@onready var time_label : Label = $Time
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func recolor(player : bool):
	if player:
		self_modulate = Color.GREEN
	else:
		self_modulate = Color.RED
		
func change_action(name : String, current : float, max : float) -> void:
	action_label.text = name
	if max == 0:
		time_label.visible = false
		max_value = 1
		value = 1
	else:
		time_label.visible = true
		max_value = max
		value = current
		time_label.text = "%.2f" % current

func update_value(current : float):
	value = current
	time_label.text = "%.2f" % current
