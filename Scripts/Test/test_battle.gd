extends Node2D

@export var left_combatant : String
@export var right_combatant : String
# Called when the node enters the scene tree for the first time.
func _ready():
	create_tween().tween_callback(run_test).set_delay(.05)

func run_test():
	$"Battle Scene".add_combatant(left_combatant, true, true)
	$"Battle Scene".add_combatant(right_combatant, false, false)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
