extends Sprite2D
class_name Combatant

@export var id : int
var occupied : bool
var current_action = 0
var queued_actions = []
var ready_time_remaining : float
var ready_timer : float

var stats : CharStats #Current stats of the entity

var action_tween : Tween


signal ready_time_changed(id : int, value : float)
signal life_changed(id : int, value : float)
# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.register_combatant(self)
	set_action_label("No Action")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ready_time_remaining > 0:
		ready_time_remaining -= delta
		if ready_time_remaining <= 0:
			ready_time_remaining = 0
			try_next_action()
		ready_time_changed.emit(id, ready_time_remaining / ready_timer)
	if !occupied and ready_time_remaining == 0:
		try_next_action()
	pass

func aura_blast(target):
	occupied = true
	print("Aura blast at " + target)

	
func punch(target):
	occupied = true
	target.occupied = true
	print("Punch at " + target.name)
	action_tween = create_tween()
	action_tween.tween_interval(2)
	action_tween.tween_callback(end_action)
	action_tween.start()
	
func end_action():
	occupied = false
	current_action.target.occupied = false
	current_action = null
	
func try_next_action():
	if occupied:
		return
	if len(queued_actions) == 0:
		return
	var action = queued_actions.pop_front()
	initiate_action(action)

func queue_action(action):
	queued_actions.append(action)

func initiate_action(action):
	$Label.text = "No Action"
	current_action = action
	match action.name:
		"aura blast": aura_blast(action.target)
		"punch": punch(action.target)

func set_action_label(action):
	$Label.text = action

func is_player() -> bool:
	return stats.player
