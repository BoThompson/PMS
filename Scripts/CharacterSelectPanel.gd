extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_character(data):
	if data == null:
		$Title.texture = load("res://Sprites/Titles/unknown.png")
		$Seal.texture = load("res://Sprites/Seals/unknown.png")
		$Style.text = "Style: Unknown"
		$Background.text = "Unknown"
		$Element.text = "Unknown"
		return
	$Title.texture = load("res://Sprites/Titles/" + data["assets"]["title_image"])
	$Seal.texture  = load("res://Sprites/Seals/" + data["assets"]["seal_image"])
	$Style.text = data["style"]
	$Background.text = data["background"]
	$Element.text = data["element"]
	var s : String
	#TODO: Populate the quirks list
	#TODO: Populate the abilities
	#TODO: Populate the sprite
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func extract_key_value(string : String):
	var key
	var value
	var idx = string.find("=")
	var result = [[null, null], -1]
	#Empty string, string with no equal sign, string starting with an equal sign
	if idx < 1:
		return result
	
	key = string.substr(0, idx).strip_edges()
	if key[0]=='\"':
		var close_idx = key.find("\"", 1)
		if close_idx == -1:
			print_debug("ERROR: No closing quote for key '" + key + "'")
			return result
		elif close_idx != len(key) - 1:
			print_debug("ERROR: malformed key '" + key + "'")
			return result
		key = string.substr(0, idx).strip_edges()
	elif key.contains(" "):
		print_debug("ERROR: malformed key '" + key + "'")
		return result
	
	value = string.substr(idx+1)
	if key[0]=='\"':
		#value = 
		var close_idx = key.find("\"", 1)
		if close_idx == -1:
			print_debug("ERROR: No closing quote for key '" + key + "'")
			return result
		elif close_idx != len(key) - 1:
			print_debug("ERROR: malformed key '" + key + "'")
			return result
