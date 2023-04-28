extends Node2D

@export var points : Array[Vector2]
var dot_base = preload("res://dot.tscn")
var min_dist = 15
var avg_dist = 20
var max_dist = 25

var surface_array = []
var verts = PackedVector3Array()
var normals = PackedVector3Array()
var colors = PackedColorArray()
var indices = PackedInt32Array()

# Called when the node enters the scene tree for the first time.
func _ready():

	
	var marks : Array[Vector2]
	for i in range(points.size() - 1):
		if(marks.size() == 0 or points[i].distance_to(marks[marks.size() - 1]) >= min_dist):
			marks.append(points[i])
		var point_a = points[i]
		var x
		if(i == points.size() - 1):
			continue
		x = i+1
		var point_b = points[x]
		var spot = point_a
		var d = point_a.distance_to(point_b)
		var direction = (point_b - point_a).normalized()
		if(d >= max_dist):
			var remaining_distance = d
			var step
			while(remaining_distance > min_dist):
				if(d > avg_dist):
					step = avg_dist
				else:
					step = min_dist
				remaining_distance -= step
				spot += step * direction
				marks.append(spot)
		elif(d >= avg_dist):
			spot += avg_dist * direction
			marks.append(spot)
		elif(d >= min_dist):
			spot += min_dist * direction
			marks.append(spot)
	for mark in marks:
		var dot = dot_base.instantiate()
		add_child(dot)
		dot.position = mark
	
	surface_array.resize(Mesh.ARRAY_MAX)
	
	
	
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_COLOR] = colors
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	#for i in range(marks.size()):
	#	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array) 
	return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
