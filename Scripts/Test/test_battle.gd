extends Node2D

@export var left_combatant : String
@export var right_combatant : String
@onready var scene : BattleScene = $"Battle Scene"

# Called when the node enters the scene tree for the first time.
func _ready():
	create_tween().tween_callback(run_test).set_delay(.05)

func run_test():
	scene.add_combatant(left_combatant, true, true)
	scene.add_combatant(right_combatant, false, false)
	scene.switch_activity(BattleScene.ActivityState.READY)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
