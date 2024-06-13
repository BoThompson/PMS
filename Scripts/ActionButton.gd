class_name ActionButton extends TextureButton


@export var action : String
@export var primary_action : bool
var affordable : bool
var data
var autofire : bool
var info_panel_template = preload("res://Templates/info_panel.tscn")
var resource_cost_template = preload("res://Templates/resource_cost_marker.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				GameManager.battle.select_action(0, action) #Player action, this name
			MOUSE_BUTTON_RIGHT:
				display_information()
	return
	
func display_information():
	var infoPanel = info_panel_template.instantiate()
	infoPanel.set_min_size(Vector2(250, 50))
	infoPanel.position = position - Vector2(50, 50)
	if infoPanel.position.x < 0:
		infoPanel.position.x = 5
	if infoPanel.position.y < 0:
		infoPanel.position.y = 5
	infoPanel.set_title(action)
	infoPanel.set_body(GameManager.actions[action].description)
	infoPanel.set_cost(GameManager.actions[action].cost)
	get_tree().root.add_child(infoPanel)
	infoPanel.popup()
	
func on_pressed():
	GameManager.select_action(true, action) #Player action, this name
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_resources_changed(values):
	affordable = false
	var post_values = values.duplicate()
	for i in range(1, len(values)):
		if data.costs[i] > values[i-1]:
			affordable = true
		else:
			post_values[i-1] -= int(data.costs[i])
	
	var any = data.costs[0]
	if any > 0:
		affordable = false
		for v in post_values:
			any -= v
			if any <= 0:
				affordable = true
				break
	show_disabled(!affordable)
	
		
func _on_auto_toggled(button_pressed : bool):
	if button_pressed:
		GameManager.battle.combatants[0].ready_time_changed.connect(_on_ready_changed)
	else:
		GameManager.battle.combatants[0].ready_time_changed.disconnect(_on_ready_changed)

func show_disabled(disable):
	if disable:
		modulate = Color.DARK_GRAY
	else:
		modulate = Color.WHITE
		
func _on_ready_changed(id, value):
	if disabled:
		autofire = true
	else:
		GameManager.battle.default_action(0, action)

func setup_costs(curr_costs):
	var offset = Vector2(6,31)
	for i in range(len(data.costs)):
		if data.costs[i] != 0:
			var marker = resource_cost_template.instantiate()
			marker.position = offset
			marker.setup(i+1, data.costs[i+1])
			add_child(marker)
			offset.x += marker.size.x + 3

func disable() -> void:
	disabled = true
	show_disabled(disabled)
	
func enable() -> void:
	disabled = false
	show_disabled(disabled and affordable)
	
func setup(name):
	action = name
	data = GameManager.get_action_data(name)
	$Icon.texture = load("res://Sprites/UI/Actions/"+data.icon)
	$"Name Label".text = name.capitalize()
	setup_costs(data.costs)
	disabled = true
	show_disabled(disabled)
	GameManager.battle.combatants[0].resources_changed.connect(_on_resources_changed)
	pass
