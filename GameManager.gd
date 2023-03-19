extends Node

var playerBoard : MatchBoard
var oppBoard : MatchBoard

var resources
# Called when the node enters the scene tree for the first time.
func _ready():
	reset_resources()


func reset_resources():
	resources = [[],[]]
	resources[0].resize(4)
	resources[1].resize(4)
	resources[0].fill(0)
	resources[1].fill(0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
