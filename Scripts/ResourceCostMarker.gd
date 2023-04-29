extends NinePatchRect

var resource_symbols = [
	preload("res://Sprites/UI/Wildcard Cost Icon.png"),
	preload("res://Sprites/UI/Attack Cost Icon.png"),
	preload("res://Sprites/UI/Defense Cost Icon.png"),
	preload("res://Sprites/UI/Focus Cost Icon.png"),
	preload("res://Sprites/UI/Aura Cost Icon.png"),
	preload("res://Sprites/UI/Yin Cost Icon.png"),
	preload("res://Sprites/UI/Yang Cost Icon.png"),
	preload("res://Sprites/UI/Earth Cost Icon.png"),
	preload("res://Sprites/UI/Water Cost Icon.png"),
	preload("res://Sprites/UI/Fire Cost Icon.png"),
	preload("res://Sprites/UI/Metal Cost Icon.png"),
	preload("res://Sprites/UI/Wood Cost Icon.png"),
	preload("res://Sprites/UI/Blood Cost Icon.png"),
	preload("res://Sprites/UI/Fury Cost Icon.png")
]

func _ready():
	pass

func _process(_delta):
	pass

func setup(type, cost):
	$Label.text = str(cost)
	var string_size = $Label.get_theme_font("font").get_string_size($Label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, $Label.get_theme_font_size("font_size"))
	$Icon.position.x = string_size.x + 5
	$"Icon Shadow".position.x = string_size.x + 7
	size.x = string_size.x + $Icon.size.x + 9
	$Icon.texture = resource_symbols[type]
	$"Icon Shadow".texture = resource_symbols[type]
		
	

