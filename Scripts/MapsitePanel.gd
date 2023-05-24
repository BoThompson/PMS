extends ColorRect

func setup(pos, name, type, description, difficulty):
	$Name.text = name
	$"Event Type".text = type
	for i in range(1,7):
		if i <= difficulty:
			get_node("D" + str(i)).visible = true
		else:
			get_node("D" + str(i)).visible = false
	$Description.text = description
	global_position = pos
