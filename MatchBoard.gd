class_name MatchBoard
extends Panel

####################################################################################################	
####################################           Members           ###################################
####################################################################################################

enum BoardState {INACTIVE, SETUP, SELECTING, SWAPPING, DRAGGING, EVALUATING, REFRESHING}
var orb_prefab = preload("res://orb.tscn")
var orbs : Array
var orbs_active : Dictionary
var start_coordinate : Vector2i
var swap_coordinate : Vector2i
var state = BoardState.INACTIVE
var swap_successful : bool
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
		
	if (state == BoardState.SELECTING or state == BoardState.DRAGGING) and event is InputEventMouseButton:
		if event.button_index & MOUSE_BUTTON_LEFT:
			
			if event.pressed:
				print(coord)
				if coord != Vector2i(-1,-1):
					orbs[coord.x][coord.y].select()
					start_coordinate = coord
					state = BoardState.DRAGGING
			else:
				print(coord)
				var diff = (coord - start_coordinate).abs()
				if coord != Vector2i(-1,-1) and ((diff.x + diff.y == 1) or (diff.x == diff.y and diff.x == 1)):
					swap_coordinate = coord
					transition()
					swap_successful = false	
				else:
					state = BoardState.SELECTING
					clear_selected(true, true)
	if event is InputEventMouseMotion and state == BoardState.DRAGGING:
		var diff = (coord - start_coordinate).abs()
		if coord != Vector2i(-1,-1) and ((diff.x + diff.y == 1) or (diff.x == diff.y and diff.x == 1)):
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
	orbs[coordinate.x][coordinate.y].queue_free()
	orbs[coordinate.x][coordinate.x] = null

func clear_orbs():
	for i in range(5):
		for j in range(5):
			if orbs[i][j] != null:
				clear_orb(Vector2i(i, j))

func clear_selected(start, end):
	if start:
		if start_coordinate != -Vector2i.ONE:
			orbs[start_coordinate.y][start_coordinate.x].deselect()
		start_coordinate = -Vector2i.ONE
	if end:
		if swap_coordinate != -Vector2i.ONE:
			orbs[swap_coordinate.y][swap_coordinate.x].deselect()
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
		

####################################################################################################	
##################################          State Methods          #################################
####################################################################################################

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
	clear_orbs()
	swap_coordinate = Vector2i(-1,-1)
	
	if fill:
		refresh()
	


	
	
func refresh() -> bool:
	var gaps = 0
	for col in range(5):
		for row in range(5):
			if orbs[col][row] == null:
				gaps += 1
			elif gaps > 0:
				orbs[col][row].fall(gaps)
				gaps -= 1
		for i in range(gaps):
			resolve_state = true
			var orb = orb_prefab.instantiate()
			orb.coordinate = Vector2i(col, 5-gaps+i)
			orb.position = Vector2(col * 64, -64 * 5 - 64 * (4 - 5 + gaps-i))
			orbs[col][5-gaps+i] = orb
			orb.board = self
			add_child(orb)
			orb.shuffle()
			orb.name = "Orb [" + str(orb.coordinate.x) + ", " + str(orb.coordinate.y) + "]"
			orb.fall(1)
		gaps = 0
	return true

	
func evaluate(test) -> bool:
	var h_checked = {}
	var v_checked = {}
	var sequences = []
	var sequence
	var activated = []
	activated.resize(25)
	activated.fill(false)
	
	if !test:
		refresh_required = false
	
	for i in range(5):
		for j in range(5):
			if h_checked.has(Vector2i(i,j)) or v_checked.has(Vector2i(i,j)):
				continue
			if(i+2 < 5 
			and orbs[j][i]
			and orbs[j][i+1] 
			and orbs[j][i+2] 
			and orbs[j][i].type == orbs[j][i+1].type 
			and orbs[j][i].type == orbs[j][i+2].type):
				sequence = [Vector2i(i,j),Vector2i(i+1,j),Vector2i(i+2,j)]
				h_checked[Vector2i(i+1,j)] = true
				h_checked[Vector2i(i+2,j)] = true
				activated[i+j*5] = true
				activated[(i+1)+j*5] = true
				activated[(i+2)+j*5] = true
				if(i+3 < 5
				and orbs[j][i+3]
				and orbs[j][i].type == orbs[j][i+3].type):
					if test:
						return true
					sequence.append(Vector2i(i+3, j))
					h_checked[Vector2i(i+3,j)] = true
					activated[(i+3)+j*5] = true
					if(i+4 < 5 
					and orbs[j][i+4]
					and orbs[j][i].type == orbs[j][i+4].type):
						sequence.append(Vector2i(i+4, j))
						h_checked[Vector2i(i+4,j)] = true
						activated[(i+4)+j*5] = true
				sequences.append(sequence)
			if(j+2 < 5 
			and orbs[j][i] 
			and orbs[j+1][i] 
			and orbs[j+2][i]
			and orbs[j][i].type == orbs[j+1][i].type 
			and orbs[j][i].type == orbs[j+2][i].type):
				if test:
						return true
				sequence = [Vector2i(i,j),Vector2i(i,j+1),Vector2i(i,j+2)]
				v_checked[Vector2i(i,j+1)] = true
				v_checked[Vector2i(i,j+2)] = true
				activated[i+j*5] = true
				activated[i+(j+1)*5] = true
				activated[i+(j+2)*5] = true
				if(j+3 < 5 
				and orbs[j+3][i]
				and orbs[j][i].type == orbs[j+3][i].type):
					sequence.append(Vector2i(i, j+3))
					v_checked[Vector2i(i,j+3)] = true
					activated[i+(j+3)*5] = true
					if(i+4 < 5 
					and orbs[j+4][i]
					and orbs[j][i].type == orbs[j][i+4].type):
						sequence.append(Vector2i(i, j+4))
						v_checked[Vector2i(i,j+3)] = true
						activated[i+(j+4)*5] = true
				sequences.append(sequence)
	
	if sequences.size() > 0:
		refresh_required = true
		swap_successful = true
		#React before activating them
		#BO - This is where to make it react to specific combos
		for i in range(25):
			if activated[i]:
				orbs[int(i/5.0)][i%5].activate()
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
			pass
		BoardState.EVALUATING:
			pass
		BoardState.REFRESHING:
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
				refresh()
			else:
				enter_state(BoardState.SELECTING)
		BoardState.REFRESHING:
			enter_state(BoardState.EVALUATING)
			evaluate(false)
	
