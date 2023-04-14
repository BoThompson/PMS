extends Object

class_name CharStats

enum CoreStage { STONE, BRONZE, SILVER, GOLD, JADE, TRANSCENDANT }

#Initialization/Reference Data
var data : Dictionary

var health : int
var max_health : int
var mind : int
var body : int
var spirit : int
var attack : int
var defense : int
var qi_attack : int
var qi_defense : int

var core_stage : CoreStage
var core_level : int

#PLAYER SPECIFIC DATA
var player : bool

#PROGRESSION STATS
var exp : int
var exp_tnl : int




var inventory

var actions : Array[String] #[0] is the basic attack, 1-8 are the optional ones

func CharStats(dataset):
	data = dataset
	health = 100
	max_health = 100
	mind = 1
	body = 1
	spirit = 1
	attack = 1
	defense = 1
	qi_attack = 1
	qi_defense = 1
	
