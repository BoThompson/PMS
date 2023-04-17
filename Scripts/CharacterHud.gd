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
func _on_ready_time_changed(_id, value):
	$"Ready Bar".update_value(value)
	
func _on_life_changed(_id, value):
	$"Character Plate/Life Bar".update_value(value)		

func setup(combatant: Combatant):
	self.combatant = combatant
	$"Character Plate/Portrait".texture = load("res://Sprites/Portraits/" + combatant.stats.data["character_select"]["assets"]["portrait_image"])
	$"Character Plate/Title".texture = load("res://Sprites/Titles/" + combatant.stats.data["character_select"]["assets"]["title_image"])
	$"Character Plate/Seal".texture = load("res://Sprites/Seals/" + combatant.stats.data["character_select"]["assets"]["seal_image"])
	
	$"Ready Bar".initialize_bar(combatant.stats.health / combatant.stats.max_health)
	combatant.ready_time_changed.connect(_on_ready_time_changed)
	combatant.life_changed.connect(_on_life_changed)
	#TODO - Put Affects here
	if !combatant.is_player():
		$"Resource Board".queue_free()
	else:
		print("Before: " + str(combatant.resources_changed.get_connections()))
		combatant.resources_changed.connect(_on_resources_changed)
		print("After: " + str(combatant.resources_changed.get_connections()))
