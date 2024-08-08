class_name BattleRecap extends Control


signal on_close()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setup(data):
	%Exp.text = str(data.xp)
	%Zin.text = str(data.money)
	return
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_okay_pressed():
	on_close.emit()
