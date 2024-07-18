class_name MapIsland extends Node2D

@export var offset_height : float
var move_tween : Tween
@export var landmark : bool
@export var site_name : String
@export var site_type : String
@export_range(1,7) var difficulty : int
@export var site_description : String
var selectable: bool = true
var mapsite_panel_template = preload("res://Templates/mapsite_panel.tscn")
var panel = null
var event_data = {
	"Name":"Dummy Event", 
	"Description":"A dummy event description", 
	"Image":"res://WIP/Test.png",
	"Options":{"Confirm":dummy_fight}
	}
# Called when the node enters the scene tree for the first time.
func _ready():
	var mat = $Sprite.material
	$Sprite.material = mat.duplicate()
	move_tween = create_tween()
	move_tween.tween_interval(randf())
	move_tween = move_tween.chain()
	move_tween.set_loops(-1)
	move_tween.tween_property(self, "position", position + Vector2(0, offset_height), 1.5 )
	move_tween.tween_property(self, "position", position + Vector2(0, -offset_height), 1.5 )
	

func _on_mouse_entered():
	if landmark:
		if panel == null:
			panel = mapsite_panel_template.instantiate()
			panel.setup($"Panel Location".global_position, site_name, site_type, site_description, difficulty)
			get_tree().root.add_child(panel)
		$Sprite.material.set_shader_parameter("width", 2)

func _on_mouse_exited():
	if landmark:
		if panel != null:
			panel.queue_free()
		$Sprite.material.set_shader_parameter("width", 0)

func _on_click(viewport, event : InputEvent, shape_idx):
	if !(event is InputEventMouseButton):
		return
	if !event.pressed:
		return
	if event.button_index != 1:
		return
	if GameManager.event_scroll != null:
		GameManager.event_scroll.roll(event_data)
	else:
		var scroll = GameManager.spawn_event_scroll()
		scroll.unroll()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#TEST
func dummy_fight():
	selectable = false
	GameManager.transition_scene("res://Scenes/map.tscn")
	
