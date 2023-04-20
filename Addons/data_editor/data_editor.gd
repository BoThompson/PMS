@tool
extends EditorPlugin

var panel 
var data
var mod_data

func _enter_tree():
	panel = preload("res://Addons/data_editor/data_editor.tscn").instantiate() as DataEditorPanel
	var data = load("res://Data/characters.json").data as Dictionary
	panel.populate_list(data)
	get_editor_interface().get_editor_main_screen().add_child(panel)

func _get_plugin_name():
	return "Data Editor"

func _has_main_screen():
	return true
	
func _get_plugin_icon():
	return get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons")

func _exit_tree():
	if panel:
		panel.queue_free()

func _make_visible(visible):
	if panel:
		panel.visible = visible
