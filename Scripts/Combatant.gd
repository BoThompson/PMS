extends Sprite2D


var id
var occupied : bool
var queued_actions = []
# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.register_combatant(self, id)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func aura_blast(target):
	occupied = true
	print("Aura blast at " + target)
	
	
func punch(target):
	print("Punch at " + target)

func initiate_action(action, target):
	if occupied:
		queued_actions.append([action, target])
	match action:
		"aura blast": aura_blast(target)
		"punch": punch(target)


