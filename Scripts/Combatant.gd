extends Sprite2D
class_name Combatant

@export var id : int
var occupied : bool
var current_action = 0
var queued_actions = []
@export var active_timer : float

var stats : CharStats #Current stats of the entity
var resources : Array[int]
var action_tween : Tween
var actions = []
var action_target

var energy_type : Orb.OrbType = Orb.OrbType.YANG

enum DamageType {PHYSICAL, ENERGY}

enum RepositionState { NONE, APPROACHING, RETURNING}
enum RepositionType { LEAP, RUN, TELEPORT }
var reposition_state : RepositionState
var reposition_type : RepositionType
var reposition_progress = 0.0
var reposition_from : Vector2
var reposition_to : Vector2

var damage_notification_template = preload("res://Templates/damage_notification.tscn")

signal resources_changed(values)
signal life_changed(id : int, value : float)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func setup(cs, player, left):
	stats = cs
	active_timer = 5
	texture = null
	var template = load("res://Templates/Battle Sprites/" + cs.data["combat"]["battle_sprite"])
	var bsprite = template.instantiate()
	add_child(bsprite)
	stats.player = player
	
	GameManager.battle
	if player:
		id = 0
	else:
		id = 1
		bsprite.get_node("Sprite").flip_h = true
	if !left:
		flip_h = true
	resources = []
	resources.resize(11)
	set_action_label("No Action")
	var action = {"name": cs.data["combat"]["basic"], "basic": true}
	actions.append(action)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if reposition_state != RepositionState.NONE:
		reposition()
	pass

func reposition():
	position = lerp(reposition_from, reposition_to, reposition_progress)
	#TODO Add some of the code for handling more complex reposition types such as the jump and land animation for leaping
	
func tween_reposition(type : RepositionType, state : RepositionState, start_pos : Vector2, end_pos : Vector2, time : float, prev_tween = null) -> Array[Tween]:
	var origin_tween : Tween
	
	if prev_tween != null:
		origin_tween = prev_tween.chain()
	else:
		origin_tween = create_tween()
	var tween = origin_tween
	tween.tween_property(self, "reposition_progress", 0, 0)
	tween = tween.chain()
	tween.tween_property(self, "reposition_from", start_pos, 0)
	tween.tween_property(self, "reposition_to", end_pos, 0)
	tween.tween_property(self, "reposition_type", type, 0)
	tween.tween_property(self, "reposition_state", state, 0)
	tween.tween_property(self, "reposition_progress", 1, time)
	tween = tween.chain()
	tween.tween_property(self, "reposition_state", RepositionState.NONE, 0)
	var tweens : Array[Tween]
	tweens.append(origin_tween)
	tweens.append(tween)
	return tweens
		
func aura_blast(target):
	occupied = true
	print("Aura blast at " + target)


func deliver_strike():
	$"BattleSprite/Animator".play("Strike")
	print_debug("TESTING!!")


#Returns true if dying from hit
func damage(amount, type = DamageType.PHYSICAL):
	#TODO: Implement defense
	#TODO: Implement damage types
	stats.health -= amount
	if(amount > 0):
		$BattleSprite/Animator.play("Hurt")
		var dam_notify = damage_notification_template.instantiate()
		dam_notify.global_position = position - Vector2(0, 50)
		dam_notify.get_node("Text").text = str(amount)
		get_tree().root.add_child(dam_notify)
		life_changed.emit(id, float(stats.health) / stats.max_health)
	if stats.health <= 0:
		return true
		die()
	return false

func die():
	queue_free()
	#TODO: Make death more satisfying?
	
func strike_hit(_count):
	action_target.damage(10)

func approach_target(tween) -> Tween:
	#TODO: Set up a position marker on combatants to show where "infront of them" should be
	var target_pos = position + (action_target.global_position - global_position)
	target_pos -= Vector2(100, 0) * sign(target_pos)
	var tweens = tween_reposition(RepositionType.LEAP, RepositionState.APPROACHING, position, target_pos, .2, tween)
	action_tween = tweens[0]
	return tweens[1]

func retreat_target(tween) -> Tween:
	var target_pos = position + (action_target.global_position - global_position)
	target_pos -= Vector2(100, 0) * sign(target_pos)
	var tweens = tween_reposition(RepositionType.LEAP, RepositionState.APPROACHING, target_pos, position, .2, tween)
	action_tween = tweens[0]
	return tweens[1]
	
func tween_action_animation(tween : Tween, animation_name : String):
	var length = $BattleSprite/Animator.get_animation(animation_name).length
	tween.tween_callback(Callable($BattleSprite/Animator, "play").bind(animation_name))
	tween.tween_interval(length)
	
func strike(target):
	occupied = true
	target.occupied = true
	action_target = target
	$BattleSprite.on_hit.connect(strike_hit)
	print("Strike start at  " + action_target.name)
	action_tween = create_tween()
	var tween_tail = tween_melee_attack(action_tween, "Strike")
	action_tween.play()

func tween_melee_attack(tween, animation_name):
	var tween_tail = approach_target(tween)
	tween_tail = tween_tail.chain()
	tween_action_animation(tween_tail, animation_name)
	tween_tail = tween_tail.chain()
	tween_tail = retreat_target(tween_tail)
	tween_tail = tween_tail.chain()
	tween_tail.tween_callback(end_action)
	return tween_tail
	
func end_action():
	for conn in $BattleSprite.on_hit.get_connections():
		$BattleSprite.on_hit.disconnect(conn.callable)
	occupied = false
	current_action.target.occupied = false
	current_action = null
	
func try_next_action() -> bool:
	if occupied:
		return false
	if len(queued_actions) == 0 and !GameManager.battle.retrieve_selected_action(id):
		return false
	if !can_afford_action(queued_actions.front()):
		return false
	var action = queued_actions.pop_front()
	pay_action_costs(action)
	initiate_action(action)
	return true

func actions_queued() -> int:
	return len(queued_actions)
	
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
	if type == Orb.OrbType.MONEY:
		gain_money(amount)
	elif type == Orb.OrbType.XP:
		gain_xp(amount, false)
	else:
		resources[type] += amount
		resources_changed.emit(resources)

func gain_money(amount) -> void:
	stats.money += amount
	pass
	
func gain_xp(amount, apply) -> void:
	stats.xp += amount
	#If apply is true, evaluate levelup conditions
	pass
	
func can_afford_action(action) -> bool:
	var high_idx = -1
	var costs = GameManager.get_action_data(action.name).costs
	var resources = Array(self.resources)
	for i in range(len(resources)):
		resources[i] -= int(costs[i+1])
		if resources[i] < 0:
			return false
		if costs[0] != 0 and (high_idx == -1 or resources[i] > resources[high_idx]):
			high_idx = i
			
			
	if high_idx != -1 and resources[high_idx] < int(costs[0]):
		return false
		
	return true
		
func pay_action_costs(action):
	var changed = false
	var high_idx = -1
	var costs = GameManager.get_action_data(action.name).costs
	for i in range(len(resources)):
		if costs[i+1] != 0:
			changed = true
		resources[i] -= int(costs[i+1])
		if costs[0] != 0 and (high_idx == -1 or resources[i] > resources[high_idx]):
			high_idx = i
	if high_idx != -1:
		resources[high_idx] -= int(costs[0])
		changed = true
	if changed:
		resources_changed.emit(resources)
		
func calculate_active_timer() -> float:
	return active_timer
