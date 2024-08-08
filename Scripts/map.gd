class_name Map extends Node2D

var islands : Dictionary = {}
@export var depth : int = 1
class island_data:
	var generated : bool = false
	var island : MapIsland = null
	var index : Vector2i
	var exits : Array[bool] = [false, false, false]
	static func create(idx : Vector2i) -> island_data:
		var isle = island_data.new()
		isle.index = idx
		return isle

var test_island = preload("res://Templates/Test/Default Island.tscn")
var portal_island = preload("res://Templates/Test/Portal Island.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.map = self
	if self == get_tree().current_scene:
		generate_map()
		populate_map()
	

func populate_map():
	for i in islands.values():
		var island : MapIsland 
		if i.index == Vector2i.ZERO:
			island = portal_island.instantiate()
		else:
			island = test_island.instantiate()
		island.name = "Island " + str(i.index)
		island.position = Vector2(400 + i.index.x * 150, 400 + i.index.y * 100 - 125 * (i.index.x+1) )
		add_child(island)


func generate_map():
	var portal = island_data.create(Vector2i(0,0))
	islands[portal.index] = portal
	var incomplete = [portal]
	while len(incomplete) > 0:
		var isle : island_data = incomplete[-1]
		incomplete.pop_back()
		islands[isle.index] = isle
		if isle.index.x >= depth - 1:
			continue
		
		generate_exits(isle)
		var idx = isle.index + Vector2i(1,0)
		for i in range(3):
			if isle.exits[i] and !islands.has(idx):
				var exit : island_data = island_data.create(idx)
				incomplete.append(exit)
			idx.y+=1

func generate_exits(isle):
	for i 	in range(3):
		if randf() >= .5:
			isle.exits[i] = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
