
class_name BattleSprite extends Node2D

signal on_hit(count)
var hit_counter = 0

var vfxes = {
	"melee_impact" :[
						"res://Templates/VFX/hit_impact_A.tscn",
						"res://Templates/VFX/hit_impact_B.tscn"
					],
	"melee_blast" : "res://Templates/VFX/melee_blast_A.tscn",
}


func reset_hit_counter():
	hit_counter = 0


func vfx(contact : int, name : String, foreground : bool = true):
	var c_node = get_node_or_null("Contacts/Contact " + str(contact))
	var vfx_resource = null
	if vfxes.has(name):
		if vfxes[name] is Array:
			vfx_resource = Tool.rand_element(vfxes[name])
		else:
			vfx_resource = vfxes[name]
		
	if c_node and vfx_resource:
		var fx = load(vfx_resource).instantiate()
		get_tree().root.add_child(fx)
		fx.global_position = c_node.global_position


func hit():
	for conn in on_hit.get_connections():
		print(conn)
	on_hit.emit(++hit_counter)
