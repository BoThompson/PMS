extends TextureButton


@export var action : String
@export var basicAttack : bool
var autofire : bool
var infoPanelPrefab = preload("res://Prefabs/info_panel.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	_on_resources_changed(GameManager.resources[0])
	set_costs(GameManager.actions[action].cost)
	GameManager.connect("playerResourcesChanged", _on_resources_changed)
	pass # Replace with function body.

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				GameManager.select_action(true, action) #Player action, this name
			MOUSE_BUTTON_RIGHT:
				display_information()
	return
	
func display_information():
	var infoPanel = infoPanelPrefab.instantiate()
	infoPanel.set_min_size(Vector2(250, 50))
	infoPanel.position = position - Vector2(50, 50)
	if infoPanel.position.x < 0:
		infoPanel.position.x = 5
	if infoPanel.position.y < 0:
		infoPanel.position.y = 5
	infoPanel.set_title(action)
	infoPanel.set_body(GameManager.actions[action].description)
	infoPanel.set_costs(GameManager.actions[action].costs)
	get_tree().root.add_child(infoPanel)
	infoPanel.popup()
	
func on_pressed():
	GameManager.select_action(true, action) #Player action, this name
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

func set_costs(costs):
	pass

func _on_resources_changed(values):
	disabled = false
	for i in range(len(values)):
		if GameManager.actions[action].cost[i] > values[i]:
			disabled = true	
	if !disabled and autofire:
		autofire = false
		GameManager.initiate_action(0, action)
	
		
func _on_auto_toggled(value):
	if value:
		GameManager.connect("playerReadyChanged", _on_ready_changed)
	else:
		GameManager.disconnect("playerReadyChanged", _on_ready_changed)

func _on_ready_changed(value):
	if value >= 1:
		if disabled:
			autofire = true
		else:
			GameManager.default_action(0, action)
	else:
		autofire = false
