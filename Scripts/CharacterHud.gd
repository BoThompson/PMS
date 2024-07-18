extends Control

var combatant : Combatant
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_resources_changed(values):
	if combatant.is_player():
		$"Resource Board"._on_resources_changed(values)

	
func _on_life_changed(_id, value):
	$"Character Plate/Life Bar".update_bar(value)		

func setup(combatant: Combatant, on_left : bool):
	self.combatant = combatant
		
	$"Character Plate/Portrait".texture = load("res://Sprites/Portraits/" + combatant.stats.data["assets"]["portrait_image"])
	$"Character Plate/Title".texture = load("res://Sprites/Titles/" + combatant.stats.data["assets"]["title_image"])
	$"Character Plate/Seal".texture = load("res://Sprites/Seals/" + combatant.stats.data["assets"]["seal_image"])
	combatant.life_changed.connect(_on_life_changed)
	#TODO - Put Affects here
	if !combatant.is_player():
		$"Resource Board".queue_free()
	else:
		combatant.resources_changed.connect(_on_resources_changed)
