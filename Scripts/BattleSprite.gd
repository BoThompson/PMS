
extends Node2D

signal on_hit(count)
var hit_counter = 0

func reset_hit_counter():
	hit_counter = 0
	
func hit():
	for conn in on_hit.get_connections():
		print(conn)
	on_hit.emit(++hit_counter)
