extends TextureRect
class_name EnergyField

####################################################################################################	
####################################           Members           ###################################
####################################################################################################

enum FieldState {INACTIVE, SETUP, SELECTING, SWAPPING, EVALUATING, REFRESHING}
var orb_prefab = preload("res://Prefabs/orb.tscn")
var orbs : Array
var orbs_active : Dictionary
var start_coordinate : Vector2i
var swap_coordinate : Vector2i
var state = FieldState.INACTIVE
var refresh_required : bool
var resolve_state : bool

var orb_size = Vector2i(50, 50)
var field_size = Vector2i(5, 5)
@export var player : bool

####################################################################################################	
################################           Default Methods           ###############################
####################################################################################################

# Called when the node enters the scene tree for the first time.
func _ready():
	resolve_state = true
	
func _input(event):

	if !(event is InputEventMouse):
		return

	var coord = get_coordinate(event.position) as Vector2i
	if coord == -Vector2i.ONE:
		if state == FieldState.SWAPPING and !is_active():
			state = FieldState.SELECTING
			clear_selected(true, true)
		return
		
	if state == FieldState.SELECTING and event is InputEventMouse:
		if event is InputEventMouseButton and event.button_index & MOUSE_BUTTON_LEFT:
			
			if event.pressed:
				print(coord)
				if coord != Vector2i(-1,-1):
					orbs[coord.x][coord.y].select()
					start_coordinate = coord
			else:
				print(coord)
				var diff = (coord - start_coordinate).abs()
				if coord != Vector2i(-1,-1) and ((diff.x + diff.y == 1) or (diff.x == diff.y and diff.x == 1)):
					swap_coordinate = coord
					transition()	
				else:
					clear_selected(true, true)
		elif event is InputEventMouseMotion and start_coordinate != -Vector2i.ONE:
			var diff = (coord - start_coordinate).abs()
			if(coord != Vector2i(-1,-1) 
			and coord != swap_coordinate
			and ((diff.x + diff.y == 1) or (diff.x == diff.y and diff.x == 1))):
				clear_selected(false, true)
				orbs[coord.x][coord.y].select()
				swap_coordinate = coord

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):	
	if resolve_state and !is_active():
		transition()
		

####################################################################################################	
################################            Helper Methods           ###############################
####################################################################################################


func is_active() -> bool:
	return orbs_active.size() > 0

func get_column(col : int):
	if col < 0 or col >= field_size.x:
		return null
	else:
		return orbs[col].copy()
		
func get_row(row : int):
	if row < 0 or row >= field_size.y:
		return null
	else:
		var rowArray : Array[Orb] = []
		for i in range(field_size.y):
			rowArray.append(orbs[i][row])
		return rowArray

func get_coordinate(pos : Vector2):
	var rect = get_global_rect()
	var tile_size = orb_size
	if !rect.has_point(pos):
		return Vector2i(-1,-1)
	else:
		var result = ((pos - position) / Vector2(tile_size)).floor()
		#result.y = field_size.y - 1 - result.y
		return Vector2i(result)

func clear_orb(coordinate):
	orbs[coordinate.x][coordinate.y] = null

func clear_orbs(destroy):
	for i in range(field_size.x):
		for j in range(field_size.y):
			if orbs[i][j] != null:
				if destroy:
					orbs[i][j].queue_free()
				clear_orb(Vector2i(i, j))

					

func clear_selected(start, end):
	if start:
		if start_coordinate != -Vector2i.ONE and orbs[start_coordinate.x][start_coordinate.y] != null:
			orbs[start_coordinate.x][start_coordinate.y].deselect()
		start_coordinate = -Vector2i.ONE
	if end:
		if swap_coordinate != -Vector2i.ONE and orbs[swap_coordinate.x][swap_coordinate.y] != null:
			orbs[swap_coordinate.x][swap_coordinate.y].deselect()
		swap_coordinate = -Vector2i.ONE
		

func swap_orbs(a, b):
	var orb_a = orbs[a.x][a.y]
	var orb_b = orbs[b.x][b.y]
	orbs[b.x][b.y] = orb_a
	orbs[a.x][a.y] = orb_b
	orb_a.swap(b)
	orb_b.swap(a)

func add_active_orb(orb):
	if orbs_active.has(orb):
		print_debug("ERROR: Tried adding active orb '" + orb.name + "' but it is already registered as active!")
	else:
		orbs_active[orb] = orb.coordinate
	
func remove_active_orb(orb):
	if !orbs_active.erase(orb):
		print_debug("ERROR: Tried removing active orb '" + orb.name + "' but isn't registered as active!")
		

func add_resource(type, amt):
	GameManager.add_resource(type, amt, 0)

####################################################################################################	
##################################          State Methods          #################################
####################################################################################################
func reset():
	state = FieldState.INACTIVE
	resolve_state = true

func setup(fill):
	#setup the orbs 2d array
	for i in range(field_size.x):
		var row : Array[Orb] = []
		row.resize(field_size.y)
		orbs.append(row)
	if player:
		GameManager.playerField = self
	else:
		GameManager.oppField = self
	
	orbs_active = {}
	clear_orbs(true)
	start_coordinate = Vector2i(-1,-1)
	swap_coordinate = Vector2i(-1,-1)
	
	if fill:
		refresh()
	


	
	
func refresh() -> bool:
	var gaps = 0
	for col in range(field_size.x):
		for row in range(field_size.y):
			var orb = orbs[col][row]
			if orbs[col][row] == null:
				gaps += 1
			elif gaps > 0:
				orb.rise(gaps)
				orbs[orb.coordinate.x][orb.coordinate.y] = orb
		for i in range(gaps):
			resolve_state = true
			var orb = orb_prefab.instantiate()
			orb.coordinate = Vector2i(col, field_size.y-gaps+i)
			orb.position = Vector2(col * orb_size.x + 36,  orb_size.y * (field_size.y+i))
			orbs[col][field_size.y-gaps+i] = orb
			orb.field = self
			add_child(orb)
			orb.shuffle()
			orb.name = "Orb [" + str(orb.coordinate.x) + ", " + str(orb.coordinate.y) + "]"
			orb.rise(0)
		gaps = 0
	return true

	
func evaluate(remove_orbs) -> bool:
	var sequences = []
	var sequence
	var activated = []
	var h_checked = []
	var v_checked = []
	activated.resize(field_size.x * field_size.y)
	h_checked.resize(field_size.x * field_size.y)
	v_checked.resize(field_size.x * field_size.y)
	activated.fill(false)
	h_checked.fill(false)
	v_checked.fill(false)
	

	if remove_orbs == false:
		refresh_required = false
	
	for col in range(field_size.x):
		for row in range(field_size.y):
			if(row+2 < field_size.x
			and !v_checked[col+row*field_size.x]
			and orbs[col][row]
			and orbs[col][row+1] 
			and orbs[col][row+2] 
			and orbs[col][row].type == orbs[col][row+1].type 
			and orbs[col][row].type == orbs[col][row+2].type):
				
				#Match found, stop
				if remove_orbs == false:
					return true
				
				#Build the sequence of 3	
				sequence = []
				for n in range(3):
					sequence.append(Vector2i(col, row+n))
					activated[col+(row+n)*field_size.x] = true
					v_checked[col+(row+n)*field_size.x] = true
				
				#Loop from 3 on to check if this pattern extends until the end of the field, stop
				#at the first failed piece
				var n = 3
				while(true):
					if(row+n < field_size.x
					and orbs[col][row+n]
					and orbs[col][row].type == orbs[col][row+n].type):
						sequence.append(Vector2i(col, row+n))
						activated[col+(row+n)*field_size.x] = true
						v_checked[col+(row+n)*field_size.x] = true
						n += 1
					else:
						break
				
				#Add it to the sequences list
				sequences.append(sequence)
				
			if(col+2 < field_size.y
			and !h_checked[col+row*field_size.x]
			and orbs[col][row] 
			and orbs[col+1][row] 
			and orbs[col+2][row]
			and orbs[col][row].type == orbs[col+1][row].type 
			and orbs[col][row].type == orbs[col+2][row].type):
				
				#Match found, stop
				if remove_orbs == false:
						return true
				
				#Build the sequence of 3	
				sequence = []
				for n in range(3):
					sequence.append(Vector2i(col+n, row))
					activated[col+n+row*field_size.x] = true
					v_checked[col+n+row*field_size.x] = true
				
				#Loop from 3 on to check if this pattern extends until the end of the field, stop
				#at the first failed piece
				var n = 3
				while(true):
					if(col+n < field_size.y
					and orbs[col+n][row]
					and orbs[col][row].type == orbs[col+n][row].type):
						sequence.append(Vector2i(col+n, row))
						activated[col+n+row*field_size.x] = true
						v_checked[col+n+row*field_size.x] = true
						n += 1
					else:
						break
				
				#Add it to the sequences list
				sequences.append(sequence)

	if sequences.size() > 0:
		refresh_required = true
		resolve_state = true
		#React before activating them
		#BO - This is where to make it react to specific combos
		for i in range(field_size.x * field_size.y):
			if activated[i]:
				orbs[i%field_size.x][int(i/field_size.y)].activate()
		return true
	
	return false
	
####################################################################################################	
#############################           State Machine Methods           ############################
####################################################################################################

func enter_state(new_state):
	resolve_state = false
	state = new_state
	match(state):
		FieldState.INACTIVE:
			pass
		FieldState.SETUP:
			setup(true)
			pass
		FieldState.SELECTING:
			pass
		FieldState.SWAPPING:
			resolve_state = true
			swap_orbs(start_coordinate, swap_coordinate)
			pass
		FieldState.EVALUATING:
			if !evaluate(true):
				transition()
			pass
		FieldState.REFRESHING:
			if refresh_required:
				refresh()
			refresh_required = false
			pass
	pass
	
func exit_state(new_state):
	match(new_state):
		FieldState.INACTIVE:
			pass
		FieldState.SETUP:
			pass
		FieldState.SELECTING:
			pass
		FieldState.SWAPPING:
			pass
		FieldState.EVALUATING:
			pass
		FieldState.REFRESHING:
			pass
	pass

func transition():
	exit_state(state)
	match(state):
		FieldState.INACTIVE:
			enter_state(FieldState.SETUP)
		FieldState.SETUP:
			enter_state(FieldState.SELECTING)
		FieldState.SELECTING:
			enter_state(FieldState.SWAPPING)

		FieldState.SWAPPING:
			#evaluate the field over and over until it's done
			if !evaluate(false):
				swap_orbs(start_coordinate, swap_coordinate)
				clear_selected(true, true)
				enter_state(FieldState.SELECTING)
			else:
				enter_state(FieldState.EVALUATING)
		FieldState.EVALUATING:
			clear_selected(true, true)	
			if refresh_required:
				enter_state(FieldState.REFRESHING)
			else:
				enter_state(FieldState.SELECTING)
		FieldState.REFRESHING:
			enter_state(FieldState.EVALUATING)
	
