extends Node2D

@export var level:Node2D
@export var next_level:PackedScene
@export var levels: Array[PackedScene]
@onready var tram_controller: Node = $TramController
@export var animal:PackedScene
@export var Coin:PackedScene

#player properties
var score:int
var max_speed:int
var morality:int = 0

var num_stops:int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tram_controller.update_tram = true
	spawn_animals()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_scene(lvl:PackedScene)->void:
	level.queue_free()
	level = lvl.instantiate()
	tram_controller.level = level
	add_child(level)
	
func load_next_level()-> void:
	load_scene(next_level)
	tram_controller.init_network()
	tram_controller.update_tram = true
	
func spawn_animals()->void:
	var animal_spawns: Node = level.animal_spawns
	for point: Marker2D in animal_spawns.top_path:
		var an: = animal.instantiate()
		add_child(an)
		an.reparent(level)
		an.position = point.position
	
	#testing coins
	#for point: Marker2D in animal_spawns.bottom_path:
		#var coin:Node2D = Coin.instantiate()
		#add_child(coin)
		#coin.position = point.position
		#coin.value = 20
	
	
