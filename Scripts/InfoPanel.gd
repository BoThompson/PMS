extends Window


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func set_body(body):
	#TODO - Bo, format the text!
	$Vertical/Body.text = body

func set_cost(cost):
	#TODO - Bo, expand the ranges
	$Vertical/Costs.visible = true
	for i in range(6):
		if cost[i] > 0:
			match i-1:
				-1: continue
				0: 	
					$Vertical/Costs/Attack.visible = true
					$Vertical/Costs/Attack/Value.text = str(cost[0])
				1:  
					$Vertical/Costs/Defense.visible = true
					$Vertical/Costs/Defense/Value.text = str(cost[1])
				2: 
					$Vertical/Costs/Focus.visible = true
					$Vertical/Costs/Focus/Value.text = str(cost[2])
				3: 
					$Vertical/Costs/Aura.visible = true
					$Vertical/Costs/Aura/Value.text = str(cost[3])
				4: 
					$Vertical/Costs/Yin.visible = true
					$Vertical/Costs/Yin/Value.text = str(cost[4])
				5: 
					$Vertical/Costs/Yang.visible = true
					$Vertical/Costs/Yang/Value.text = str(cost[5])

func _on_popup_hide():
	queue_free()
