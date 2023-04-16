extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_ready_time_changed(_id, value):
	$"Ready Bar".update_value(value)
	
func _on_life_changed(_id, value):
	$"Character Plate/Life Bar".update_value(value)		

func setup(combatant: Combatant):
	$"Character Plate/Portrait".texture = load("res://Sprites/Portraits/" + combatant.stats.data["character_select"]["assets"]["portrait_image"])
	$"Character Plate/Portrait".texture = load("res://Sprites/Titles/" + combatant.stats.data["character_select"]["assets"]["title_image"])
	$"Ready Bar".initialize_bar(combatant.stats.health / combatant.stats.max_health)
	#TODO - Put Affects here
	if !combatant.is_player():
		$"Resource Board".queue_free()
