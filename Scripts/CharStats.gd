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
var xp : int
var xp_tnl : int

var money : int



var inventory

var actions : Array[String] #[0] is the basic attack, 1-8 are the optional ones

static func load(dataset):
	var cs = CharStats.new()
	cs.data = dataset
	cs.health = 20
	cs.max_health = 20
	cs.mind = 1
	cs.body = 1
	cs.spirit = 1
	cs.attack = 1
	cs.defense = 1
	cs.qi_attack = 1
	cs.qi_defense = 1
	return cs
	
