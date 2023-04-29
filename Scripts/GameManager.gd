extends Node


const characters_data = preload("res://Data/characters.json").data
const action_data = preload("res://Data/actions.json").data
var battle : BattleScene


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	


func get_action_data(name):
	return action_data[name]
