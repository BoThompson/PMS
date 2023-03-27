extends Control

@export var title : String
@export var locked : bool
var tween : Tween
var start_position : Vector2
# Called when the node enters the scene tree for the first time.
func _ready():
	start_position = position
	if locked:
		$Button.modulate = Color(.4, .4, .4, 1)
	set_passive()
	pass # Replace with function body.

func _on_mouse_entered():
	if tween:
		tween.stop()
		set_passive()
	tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "position", start_position + Vector2(-2, -2), .2)
	tween.tween_property($Shadow, "position", Vector2(4, 4), .2)
	if locked:
		tween.tween_property($Lock, "modulate:a", 0, .1)
		var second = tween.chain()
		second.tween_property($Requirement, "modulate:a", 1, .1)
		second.tween_property($Portrait, "modulate", Color(0,0,0, .4), .1)
	else:
		tween.tween_property($Dimmer, "modulate:a", 0, .2)
	
func _on_mouse_exited():
	if tween:
		tween.stop()
		set_active()
	tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "position", start_position, .2)
	tween.tween_property($Shadow, "position", Vector2.ZERO, .2)
	if locked:
		tween.tween_property($Requirement, "modulate:a", 0, .1)
		var second = tween.chain()
		second.tween_property($Lock, "modulate:a", 1, .1)
		second.tween_property($Portrait, "modulate", Color(0,0,0, 0), .1)
	else:
		tween.tween_property($Dimmer, "modulate:a", .3, .2)

func set_active():
	$Lock.modulate.a = 0
	self.position = start_position + Vector2(-2, -2)
	$Shadow.position = Vector2(4, 4)
	if locked:
		$Requirement.modulate.a = 1
		$Portrait.modulate = Color(0,0,0,.4)
	else:
		$Requirement.modulate.a = 0
		$Seal.modulate.a = .3
		$Title.modulate.a = 1
		$Portrait.modulate.a = 1
		$Quote.modulate.a = 1
		$Dimmer.modulate.a = 0
		
func set_passive():
	self.position = start_position
	$Shadow.position = Vector2(0, 0)
	if locked:
		$Lock.modulate.a = 1
		$Requirement.modulate.a = 0
		$Seal.modulate.a = 0
		$Title.modulate.a = 0
		$Portrait.modulate = Color(0,0,0,0)
		$Quote.modulate.a = 0
		$Dimmer.modulate.a = 0
	else:
		$Lock.modulate.a = 0
		$Dimmer.modulate.a = .3
		
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_selected():
	print(title + " selected.")
	pass # Replace with function body.
