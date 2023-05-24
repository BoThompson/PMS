extends Sprite2D

@export var offset_height : float
var move_tween : Tween
@export var landmark : bool
@export var site_name : String
@export var site_type : String
@export_range(1,7) var difficulty : int
@export var site_description : String
var mapsite_panel_prefab = preload("res://Prefabs/mapsite_panel.tscn")
var panel = null
# Called when the node enters the scene tree for the first time.
func _ready():
	move_tween = create_tween()
	move_tween.tween_interval(randf())
	move_tween = move_tween.chain()
	move_tween.set_loops(-1)
	move_tween.tween_property(self, "position", position + Vector2(0, offset_height), 1.5 )
	move_tween.tween_property(self, "position", position + Vector2(0, -offset_height), 1.5 )
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if landmark:
		var crect = get_rect()
		crect.position += global_position
		print(crect)
		print(get_viewport().get_mouse_position())
		if crect.has_point(get_viewport().get_mouse_position()):
			if panel == null:
				panel = mapsite_panel_prefab.instantiate()
				panel.setup($"Panel Location".global_position, site_name, site_type, site_description, difficulty)
				get_tree().root.add_child(panel)
			material.set_shader_parameter("width", 2)
		else:
			if panel != null:
				panel.queue_free()
			material.set_shader_parameter("width", 0)
	pass
