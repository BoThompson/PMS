@tool
extends Control

class_name DataEditorPanel

var data
var pre_data
var char_list = []
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func populate_list(data):
	self.data = data
	self.pre_data = data.duplicate(true)
	for char in data.keys():
		char_list.append(char)
		$Panel/Scroll/List.add_item(char)
	$Panel/Scroll/List.connect("item_selected", _on_character_selected)
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _on_character_selected(idx):
	populate_panel(char_list[idx])

func populate_panel(char):
	var cd = data[char]
	var cs = cd["character_select"]
	$Panel/Name.text = char
	$Panel/Style.text = cs.style
	$Panel/Background.text = cs.background
	$Panel/Element.text = cs.element
	$Panel/Title.texture = load("res://Sprites/Titles/" + cs.assets.title_image)
	$Panel/Seal.texture = load("res://Sprites/Seals/" +cs.assets.seal_image)
	$Panel/Sprite.texture = load("res://Sprites/Battle Sprites/" +cs.assets.sprite)
	$Panel/Portrait.texture = load("res://Sprites/Portraits/" +cs.assets.portrait_image)
	

func _process(delta):
	pass
