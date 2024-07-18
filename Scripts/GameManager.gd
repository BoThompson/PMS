extends Node


const characters_data = preload("res://Data/characters.json").data
const action_data = preload("res://Data/actions.json").data
var battle : BattleScene
var event_scroll
var event_scroll_template = preload("res://Templates/event_scroll.tscn")
var blinder_template = preload("res://Templates/blinder.tscn")
var blind_tween : Tween
var map : Map

var current_data

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func spawn_event_scroll():
	event_scroll = event_scroll_template.instantiate()
	get_tree().root.add_child(event_scroll)
	return event_scroll

func get_action_data(name):
	return action_data[name]

func transition_scene(scene_path):
	var tween : Tween
	if blind_tween != null:
		tween = blind_tween
	else:
		tween = create_tween()
	var blinder = blinder_template.instantiate()
	add_child(blinder)
	tween.tween_property(blinder, "modulate:a", 1, .25)
	tween.tween_callback(func(): if map and map.get_parent() == get_tree().root: get_tree().root.remove_child(map))
	tween.tween_callback(func(): get_tree().change_scene_to_file(scene_path))
	tween.tween_interval(.2)
	tween.tween_property(blinder, "modulate:a", 0, .25)
	tween.tween_callback(func(): print("Reached");blinder.queue_free(); blind_tween = null)
	blind_tween = tween

func launch_trial(character):
	current_data = character
	transition_scene("res://Scenes/map.tscn")


func transition_map():
	if !map:
		printerr("Map missing for transition_map call")
		return
		
	if map.get_parent() == get_tree().root:
		print("Map already in scene tree for transition_map call")
		return
	var tween : Tween
	if blind_tween != null:
		tween = blind_tween
	else:
		tween = create_tween()
	var blinder = blinder_template.instantiate()
	add_child(blinder)
	tween.tween_property(blinder, "modulate:a", 1, .25)
	tween.tween_callback(get_tree().unload_current_scene)
	tween.tween_callback(func(): get_tree().add_child(map))
	tween.tween_callback(func(): get_tree().current_scene = map)
	tween.tween_interval(.2)
	tween.tween_property(blinder, "modulate:a", 0, .25)
	tween.tween_callback(blinder.queue_free)
	blind_tween = tween
