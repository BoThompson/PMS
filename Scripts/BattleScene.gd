extends Node2D

class_name BattleScene
const action_button_template = preload("res://Templates/action_button.tscn")
const basic_action_button_template = preload("res://Templates/basic_action_button.tscn")
var action_buttons : Array[ActionButton] = [null]

const combatant_template = preload("res://Templates/combatant.tscn")
var energy_field : EnergyField

var playerResourceBoard : ResourceBoard
var oppResourceBoard : ResourceBoard

enum ActivityState {READY, GATHER, ACTION, BLITZ, COMPLETE}
var activity : ActivityState = ActivityState.READY

var combatants : Dictionary = {}
var player_turn : bool = true
var selected_actions : Array = [null, null]
var resolve_actions : bool
@onready var timer : Timer = $Timer
@onready var timer_bar : ActiveTimer = %"Timer Bar"

const player_hud : PackedScene = preload("res://Templates/player_hud.tscn")
const enemy_hud : PackedScene = preload("res://Templates/enemy_hud.tscn")
	

func add_action_button(action):
	var name = action.name
	var primary = action.basic
	if primary:
		if action_buttons[0] != null:
			action_buttons[0].queue_free()
		action_buttons[0] = basic_action_button_template.instantiate()
		$HUD.add_child(action_buttons[0])
		action_buttons[0].position = Vector2(15, 285)
		action_buttons[0].setup(name)
	elif len(action_buttons) >= 9:
		print("ERROR: Attempted to add too many action buttons.")
	else:
		var idx = len(action_buttons)
		action_buttons.append(action_button_template.instantiate())
		$HUD.add_child(action_buttons[idx])
		action_buttons[idx].position = Vector2(15 + 130 * (idx % 2), 295 + 58 * int(idx/2))
		action_buttons[idx].setup(name)

func disable_action_buttons() -> void:
	for button in action_buttons:
		button.disable()
		
func enable_action_buttons() -> void:
	for button in action_buttons:
		button.enable()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if !timer.is_stopped():
		timer_bar.update_value(timer.time_left)
		
	if energy_field and !energy_field.resolve_state and resolve_actions:
		var unoccupied = true
		var awaiting = false
			
		for comb in combatants.values():
			if comb.occupied:
				unoccupied = false
			if comb.actions_queued():
				awaiting = true
			
		if unoccupied:
			match activity:
				ActivityState.BLITZ:
					if timer.is_stopped():
						switch_activity(ActivityState.COMPLETE)
					elif awaiting:
						advance_action_queue()
					else:
						resolve_actions = false
					
				ActivityState.ACTION:
					if !awaiting:
						resolve_actions = false
						switch_activity(ActivityState.COMPLETE)
					else:
						advance_action_queue()
		
	elif activity == ActivityState.BLITZ:
		if timer.is_stopped():
			switch_activity(ActivityState.COMPLETE)
		else:
			advance_action_queue()
	
	return

func advance_action_queue():
	if player_turn:
		while combatants[0].actions_queued() > 0:
			if combatants[0].try_next_action():
				resolve_actions = true
				return
	else:
		for key in combatants.keys():
			if key == 0: #The player gets skipped
				continue
			if (combatants[key].actions_queued() > 0
			and combatants[key].try_next_action()):
				resolve_actions = true
				return


func add_combatant(combatant_name, is_player, on_left):
	var combatant = combatant_template.instantiate()
	var data = GameManager.characters_data[combatant_name]
	var cs = CharStats.load(data)
	combatant.setup(cs, is_player, on_left)
	combatant.position.y += 25
	if !on_left:
		combatant.position.x = 960 - combatant.position.x
	register_combatant(combatant, on_left)
	get_tree().root.add_child(combatant)

func get_opponent(id) -> Combatant:
	if id == 0:
		return combatants[1]
	else:
		return combatants[0]


func queue_action(id, action):
	var opp = get_opponent(id)
	combatants[0].queue_action({"name":action, "target":get_opponent(id)})
	

func register_combatant(combatant : Combatant, on_left : bool):
	combatants[combatant.id] = combatant
	var hud
	if on_left:
		hud = player_hud.instantiate()
	else:
		hud = enemy_hud.instantiate()
	#setup the buttons
	if combatant.is_player():
		for action in combatant.actions:
			var button = add_action_button(action)
	hud.setup(combatant, on_left)
	get_tree().root.add_child(hud)
	combatant.on_defeat.connect(_on_combatant_defeat)
	if combatant.is_player():
		hud.position = Vector2(10,10)
	else:
		hud.position = Vector2(780, 10)

func spawn_action_button(action):
	var button
	if len(action_buttons) == 0:
		button = basic_action_button_template.instantiate()
	else:
		button = action_button_template.instantiate()
		
func default_action(id, action):
	if selected_actions[id] != null:
		return false
	select_action(id, action)
	return true

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.battle = self
	selected_actions = []
	selected_actions.resize(2)
	selected_actions.fill(null)

func retrieve_selected_action(id):
	if selected_actions[id] != null:
		queue_action(id, selected_actions[id])
		return true
	else:
		return false

func pass_selected():
	if activity == ActivityState.READY:
		if player_turn:
			energy_field.get_meditation_energy()
			reset_energy_field()
		else:
			var desired_types = {}
			for c : Combatant in combatants.values():
				if !c.is_player():
					desired_types[c.energy_type] = c.energy_type
			energy_field.get_enemy_energy(desired_types.keys())
			var tween = create_tween()
			tween.tween_interval(.75)
			tween.tween_callback(Callable(self, "switch_activity").bind(ActivityState.ACTION))
	elif activity == ActivityState.ACTION:
		reset_energy_field()
		switch_activity(ActivityState.COMPLETE)
		

func reset_energy_field():
	energy_field.reset()


func add_resource(resource, amt, id=-1):
	if player_turn:
		id = 0
	else:
		id = 1
	combatants[id].add_resource(resource, amt)

func select_action(id, action) -> bool:
	
	if id == 0 != player_turn:
		return false

	queue_action(id, action)
	if activity == ActivityState.READY:
		switch_activity(ActivityState.BLITZ)
		resolve_actions = true
	elif activity == ActivityState.ACTION:
		disable_action_buttons()
		advance_action_queue()
	return true

func switch_activity (act : ActivityState) -> void:
	activity = act
	match(act):
		ActivityState.READY:
			timer_bar.recolor(player_turn)
			%"Pass Button".disabled = !player_turn
			if player_turn:
				energy_field.unlock()
				enable_action_buttons()
				%"Pass Button".text = "MEDITATE"
			else:
				energy_field.lock()
				disable_action_buttons()
				var tween = create_tween()
				tween.tween_interval(1)
				tween.tween_callback(Callable(self, "pass_selected"))
				return
		ActivityState.GATHER:
			%"Pass Button".disabled = true
			disable_action_buttons()
		ActivityState.ACTION:
			if player_turn:
				%"Pass Button".disabled = false
				%"Pass Button".text = "SCATTER"
				enable_action_buttons()
				energy_field.lock()
				energy_field.try_evaluate()
			else:
				enemy_action()
		ActivityState.BLITZ:
			energy_field.lock()
		ActivityState.COMPLETE:
			disable_action_buttons()
			player_turn = !player_turn
			switch_activity(ActivityState.READY)
	start_active_timer()

func start_active_timer() -> void:
	var time = get_active_timer(player_turn)
	var act_name = ""
	match activity:
		ActivityState.READY:
			act_name = "READY"
			time = 0
		ActivityState.GATHER:
			act_name = "GATHERING"
		ActivityState.ACTION:
			act_name = "ACTION"
			time = 0
		ActivityState.BLITZ:
			act_name = "BLITZ!!!"
	if time == 0:
		timer.stop()
	else:
		timer.start(time)
	timer_bar.change_action(act_name, time, time)

func get_active_timer(player_turn) -> float:
	if player_turn:
		return combatants[0].calculate_active_timer()
	else:
		var time = 0
		for combatant in combatants.values():
			if combatant.id != 0:
				time += combatant.calculate_active_timer()
		return time
	
func _on_active_timer_complete():
	match(activity):
		ActivityState.GATHER:
			switch_activity(ActivityState.ACTION)

func _on_energy_field_gathering():
	if activity == ActivityState.READY:
		switch_activity(ActivityState.GATHER)

func _on_combatant_defeat(id : int, cause : String):
	
	if id == 0:
		print("YOU LOST!")
		get_tree().quit()
	else:
		print("YOU WON!")
		get_tree().quit()
	pass
	
	
func enemy_action():
	for combatant : Combatant in combatants.values():
		if !combatant.is_player():
			combatant.queue_enemy_action()
	resolve_actions = true
