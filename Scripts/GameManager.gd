extends Node


const characters_data = preload("res://Data/characters.json").data
const action_data = preload("res://Data/actions.json").data
var battle : BattleScene
var event_scroll
var event_scroll_template = preload("res://Templates/event_scroll.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func spawn_event_scroll():
	event_scroll = event_scroll_template.instantiate()
	get_tree().root.add_child(event_scroll)
	return event_scroll

func get_action_data(name):
	return action_data[name]
