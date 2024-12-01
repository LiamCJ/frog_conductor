extends Node2D

@export var level:Node2D
@export var next_level:PackedScene
@export var levels: Array[PackedScene]
@onready var tram_controller: Node = $TramController
@export var animals: Array[PackedScene]
var top_animals: Array[Area2D]
var bottom_animals: Array[Area2D]
@export var Coin:PackedScene

#player properties
var score:int
var max_speed:int
var morality:int = 0

var num_stops:int = 5
var top_path_chosen:bool

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
	
func on_animal_hit(animal:Area2D) ->void:
	animal.kill()
	if animal == top_animals[0]: 
		top_path_chosen = true
		tram_controller.speed = 0
		move_animals_to_tram()
	elif animal == bottom_animals[0]:
		top_path_chosen = false
		tram_controller.speed = 0
		move_animals_to_tram()

func move_animals_to_tram()->void:
	var markers: Array[Marker2D]
	var animals_to_move: Array[Area2D]
	var goal_pos: Vector2
	
	for animal in top_animals:
		animal.set_deferred('monitorable',false)
	for animal in bottom_animals:
		animal.set_deferred('monitorable',false)
	
	if top_path_chosen:
		markers =  level.animal_spawns.bottom_path
		animals_to_move = bottom_animals
		goal_pos = level.animal_spawns.top_path[0].position
	else:
		markers =  level.animal_spawns.top_path
		animals_to_move = top_animals
		goal_pos = level.animal_spawns.bottom_path[0].position
	
	for i:int in range(animals_to_move.size()):
		animals_to_move[i].add_waypoint(markers[0].position)
		animals_to_move[i].add_waypoint(goal_pos)
		animals_to_move[i].movement_ended.connect(add_to_tram)

func add_to_tram(animal:Area2D)->void:
	animal.queue_free()

func spawn_animal_row(markers:Array[Marker2D],amount:int)->Array[Area2D]:	
	var _animals: Array[Area2D]
	for i:int in range(amount):
		
		#choose random animal
		var animal_idx:int = randi_range(0,animals.size() - 1)
		var new_animal:Area2D = animals[animal_idx].instantiate()
		#set position of animal to marker
		new_animal.position = markers[i].position
		
		level.add_child(new_animal) #animals added to level so they are freed with it
		#note: cant access children (coin) before setting parent
		new_animal.set_value(randi_range(1,9)*10)
		_animals.append(new_animal)
	return _animals
	
func spawn_animals()->void:
	top_animals.clear()
	bottom_animals.clear()
	
	var animal_markers: Node = level.animal_spawns
	
	#choose random number of animals to spawn
	var num_top:int = randi_range(1,animal_markers.top_path.size())
	top_animals = spawn_animal_row(animal_markers.top_path,num_top)
	
	#same for bottom rail
	var num_bottom:int = randi_range(1,animal_markers.bottom_path.size())
	bottom_animals = spawn_animal_row(animal_markers.bottom_path,num_bottom)

