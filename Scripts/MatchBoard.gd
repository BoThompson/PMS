class_name MatchBoard
extends Panel

####################################################################################################	
####################################           Members           ###################################
####################################################################################################

enum BoardState {INACTIVE, SETUP, SELECTING, SWAPPING, EVALUATING, REFRESHING}
var orb_prefab = preload("res://orb.tscn")
var orbs : Array
var orbs_active : Dictionary
var start_coordinate : Vector2i
var swap_coordinate : Vector2i
var state = BoardState.INACTIVE
var refresh_required : bool
var resolve_state : bool

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
		if state == BoardState.SWAPPING and !is_active():
			state = BoardState.SELECTING
			clear_selected(true, true)
		return
		
	if state == BoardState.SELECTING and event is InputEventMouse:
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
	if col < 0 or col > 4:
		return null
	else:
		return orbs[col].copy()
		
func get_row(row : int):
	if row < 0 or row > 4:
		return null
	else:
		var rowArray : Array[Orb] = []
		for i in range(5):
			rowArray.append(orbs[i][row])
		return rowArray

func get_coordinate(pos : Vector2):
	var rect = get_global_rect()
	var tile_size = rect.size.x / 5
	if !rect.has_point(pos):
		return Vector2i(-1,-1)
	else:
		var result = ((pos - position) / tile_size).floor()
		result.y = 4 - result.y
		return Vector2i(result)

func clear_orb(coordinate):
	orbs[coordinate.x][coordinate.y] = null

func clear_orbs(destroy):
	for i in range(5):
		for j in range(5):
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
	GameManager.add_resource(type, amt, player)

####################################################################################################	
##################################          State Methods          #################################
####################################################################################################
func reset():
	state = BoardState.INACTIVE
	resolve_state = true

func setup(fill):
	#setup the orbs 2d array
	for i in range(5):
		var row : Array[Orb] = []
		row.resize(5)
		orbs.append(row)
	if player:
		GameManager.playerBoard = self
	else:
		GameManager.oppBoard = self
	
	orbs_active = {}
	clear_orbs(true)
	start_coordinate = Vector2i(-1,-1)
	swap_coordinate = Vector2i(-1,-1)
	
	if fill:
		refresh()
	


	
	
func refresh() -> bool:
	var gaps = 0
	for col in range(5):
		for row in range(5):
			var orb = orbs[col][row]
			if orbs[col][row] == null:
				gaps += 1
			elif gaps > 0:
				orb.fall(gaps)
				orbs[orb.coordinate.x][orb.coordinate.y] = orb
		for i in range(gaps):
			resolve_state = true
			var orb = orb_prefab.instantiate()
			orb.coordinate = Vector2i(col, 5-gaps+i)
			orb.position = Vector2(col * 64, -32 * 5 - 64 * (-gaps+i+1))
			orbs[col][5-gaps+i] = orb
			orb.board = self
			add_child(orb)
			orb.shuffle()
			orb.name = "Orb [" + str(orb.coordinate.x) + ", " + str(orb.coordinate.y) + "]"
			orb.fall(0)
		gaps = 0
	return true

	
func evaluate(remove_orbs) -> bool:
	var sequences = []
	var sequence
	var activated = []
	var h_checked = []
	var v_checked = []
	activated.resize(25)
	h_checked.resize(25)
	v_checked.resize(25)
	activated.fill(false)
	h_checked.fill(false)
	v_checked.fill(false)
	

	if remove_orbs == false:
		refresh_required = false
	
	for col in range(5):
		for row in range(5):
			if(row+2 < 5
			and !v_checked[col+row*5]
			and orbs[col][row]
			and orbs[col][row+1] 
			and orbs[col][row+2] 
			and orbs[col][row].type == orbs[col][row+1].type 
			and orbs[col][row].type == orbs[col][row+2].type):
				sequence = [Vector2i(col,row),Vector2i(col,row+1),Vector2i(col,row+2)]
				activated[col+row*5] = true
				activated[col+(row+1)*5] = true
				activated[col+(row+2)*5] = true
				v_checked[col+row*5] = true
				v_checked[col+(row+1)*5] = true
				v_checked[col+(row+2)*5] = true
				if remove_orbs == false:
					return true
				if(row+3 < 5
				and orbs[col][row+3]
				and orbs[col][row].type == orbs[col][row+3].type):
					sequence.append(Vector2i(col, row+3))
					activated[col+(row+3)*5] = true
					v_checked[col+(row+3)*5] = true
					if(row+4 < 5 
					and orbs[col][row+4]
					and orbs[col][row].type == orbs[col][row+4].type):
						sequence.append(Vector2i(col, row+4))
						activated[col+(row+4)*5] = true
						v_checked[col+(row+4)*5] = true
				sequences.append(sequence)
			if(col+2 < 5
			and !h_checked[col+row*5]
			and orbs[col][row] 
			and orbs[col+1][row] 
			and orbs[col+2][row]
			and orbs[col][row].type == orbs[col+1][row].type 
			and orbs[col][row].type == orbs[col+2][row].type):
				if remove_orbs == false:
						return true
				sequence = [Vector2i(col,row),Vector2i(col+1,row),Vector2i(col+2,row)]
				activated[col+row*5] = true
				activated[col+1+row*5] = true
				activated[col+2+row*5] = true
				h_checked[col+row*5] = true
				h_checked[col+1+row*5] = true
				h_checked[col+2+row*5] = true
				if(col+3 < 5 
				and orbs[col+3][row]
				and orbs[col][row].type == orbs[col+3][row].type):
					sequence.append(Vector2i(col+3, row))
					activated[col+3+row*5] = true
					h_checked[col+3+row*5] = true
					if(col+4 < 5 
					and orbs[col+4][row]
					and orbs[col][row].type == orbs[col+4][row].type):
						sequence.append(Vector2i(col+4, row))
						activated[col+4+row*5] = true
						h_checked[col+4+row*5] = true
				sequences.append(sequence)

	if sequences.size() > 0:
		refresh_required = true
		resolve_state = true
		#React before activating them
		#BO - This is where to make it react to specific combos
		for i in range(25):
			if activated[i]:
				orbs[i%5][int(i/5.0)].activate()
		return true
	
	return false
	
####################################################################################################	
#############################           State Machine Methods           ############################
####################################################################################################

func enter_state(new_state):
	resolve_state = false
	state = new_state
	match(state):
		BoardState.INACTIVE:
			pass
		BoardState.SETUP:
			setup(true)
			pass
		BoardState.SELECTING:
			pass
		BoardState.SWAPPING:
			resolve_state = true
			swap_orbs(start_coordinate, swap_coordinate)
			pass
		BoardState.EVALUATING:
			if !evaluate(true):
				transition()
			pass
		BoardState.REFRESHING:
			if refresh_required:
				refresh()
			refresh_required = false
			pass
	pass
	
func exit_state(new_state):
	match(new_state):
		BoardState.INACTIVE:
			pass
		BoardState.SETUP:
			pass
		BoardState.SELECTING:
			pass
		BoardState.SWAPPING:
			pass
		BoardState.EVALUATING:
			pass
		BoardState.REFRESHING:
			pass
	pass

func transition():
	exit_state(state)
	match(state):
		BoardState.INACTIVE:
			enter_state(BoardState.SETUP)
		BoardState.SETUP:
			enter_state(BoardState.SELECTING)
		BoardState.SELECTING:
			enter_state(BoardState.SWAPPING)

		BoardState.SWAPPING:
			#evaluate the board over and over until it's done
			if !evaluate(false):
				swap_orbs(start_coordinate, swap_coordinate)
				clear_selected(true, true)
				enter_state(BoardState.SELECTING)
			else:
				enter_state(BoardState.EVALUATING)
		BoardState.EVALUATING:
			clear_selected(true, true)	
			if refresh_required:
				enter_state(BoardState.REFRESHING)
			else:
				enter_state(BoardState.SELECTING)
		BoardState.REFRESHING:
			enter_state(BoardState.EVALUATING)
	
