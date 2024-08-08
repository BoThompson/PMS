extends Control

var combatant : Combatant
const orb_coordinates : Dictionary = {
	Orb.OrbType.YIN: Vector2(0,0),
	Orb.OrbType.YANG: Vector2(0,1),
	Orb.OrbType.ATTACK: Vector2(0,2),
	Orb.OrbType.DEFENSE: Vector2(0,3),
	Orb.OrbType.AURA: Vector2(0,4),
	Orb.OrbType.FOCUS: Vector2(0,5),
	Orb.OrbType.MONEY: Vector2(0,6),
	Orb.OrbType.XP: Vector2(0,7),
}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_resources_changed(values):
	if combatant.is_player():
		$"Resource Board"._on_resources_changed(values)
	else:
		var type = combatant.energy_type
		%Energy.text = str(values[combatant.energy_type])
		if values[type] > 0:
			%Orb.modulate = Color.WHITE
		else:
			%Orb.modulate = Color.DARK_GRAY

	
func _on_life_changed(_id, value):
	$"Character Plate/Life Bar".update_bar(value)		

func setup(combatant: Combatant, on_left : bool):
	self.combatant = combatant
		
	$"Character Plate/Portrait".texture = load("res://Sprites/Portraits/" + combatant.stats.data["assets"]["portrait_image"])
	$"Character Plate/Title".texture = load("res://Sprites/Titles/" + combatant.stats.data["assets"]["title_image"])
	$"Character Plate/Seal".texture = load("res://Sprites/Seals/" + combatant.stats.data["assets"]["seal_image"])
	if !combatant.is_player():
		%Orb.frame_coords = orb_coordinates[combatant.energy_type]
	combatant.life_changed.connect(_on_life_changed)
	#TODO - Put Affects here
	combatant.resources_changed.connect(_on_resources_changed)
