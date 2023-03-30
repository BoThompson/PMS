extends TextureButton


@export var attack : String
var infoPanelPrefab = preload("res://Prefabs/info_panel.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				GameManager.select_action(true, attack) #Player action, this name
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
	infoPanel.set_title(attack)
	infoPanel.set_body(GameManager.attacks[attack].description)
	infoPanel.set_costs(GameManager.attacks[attack].costs)
	get_tree().root.add_child(infoPanel)
	infoPanel.popup()
	
func on_pressed():
	GameManager.select_action(true, attack) #Player action, this name
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
