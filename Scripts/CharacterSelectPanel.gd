extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_character(data):
	$Title.texture = load("res://Sprites/Titles/" + data["assets"]["title_image"])
	$Seal.texture  = load("res://Sprites/Seals/" + data["assets"]["seal_image"])
	$Style.text = data["style"]
	$Background.text = data["background"]
	$Element.text = data["element"]
	#TODO: Populate the quirks list
	#TODO: Populate the abilities
	#TODO: Populate the sprite
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
