extends Sprite2D
class_name Combatant

@export var id : int
var occupied : bool
var current_action = 0
var queued_actions = []
var ready_time_remaining : float
@export var ready_timer : float

var stats : CharStats #Current stats of the entity
var resources : Array[int]
var action_tween : Tween
var actions = []

signal resources_changed(values)
signal ready_time_changed(id : int, value : float)
signal life_changed(id : int, value : float)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func setup(cs, player, left):
	ready_time_remaining = ready_timer
	stats = cs
	texture = load("res://Sprites/Battle Sprites/" + cs.data["character_select"]["assets"]["sprite"])
	stats.player = player
	if player:
		id = 0
	else:
		id = 1
	if !left:
		flip_h = true
	resources = []
	resources.resize(11)
	set_action_label("No Action")
	var action = {"name": cs.data["basic"], "basic": true}
	actions.append(action)

	
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

	
func strike(target):
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
	if len(queued_actions) == 1:
		$Label.text = action.name

func initiate_action(action):
	$Label.text = "No Action"
	current_action = action
	match action.name:
		"aura blast": aura_blast(action.target)
		"strike": strike(action.target)

func set_action_label(action):
	$Label.text = action

func is_player() -> bool:
	return stats.player

func add_resource(type : int, amount : int):
	resources[type] += amount
	resources_changed.emit(resources)
	for c in resources_changed.get_connections():
		print(c)
	
