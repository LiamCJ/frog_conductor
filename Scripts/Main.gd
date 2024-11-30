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
	if animal == top_animals[0] or animal == bottom_animals[0]:
		tram_controller.speed = 0

func spawn_animals()->void:
	top_animals.clear()
	bottom_animals.clear()
	
	var animal_markers: Node = level.animal_spawns
	
	#choose random number of animals to spawn
	var num_top:int = randi_range(1,animal_markers.top_path.size())
	for i:int in range(num_top):
		#choose random animal
		var animal_idx:int = randi_range(0,animals.size() - 1)
		var new_animal:Area2D = animals[animal_idx].instantiate()
		#set position of animal to marker
		new_animal.position = animal_markers.top_path[i].position
		
		
		level.add_child(new_animal) #animals added to level so they are freed with it
		#note: cant access children (coin) before setting parent
		new_animal.set_value(randi_range(1,9)*10)
		top_animals.append(new_animal)

	var num_bottom:int = randi_range(1,animal_markers.bottom_path.size())
	for i:int in range(num_bottom):
		var animal_idx:int = randi_range(0,animals.size() - 1)
		var new_animal:Area2D = animals[animal_idx].instantiate()
		new_animal.position = animal_markers.bottom_path[i].position
		level.add_child(new_animal)
		new_animal.set_value(randi_range(1,9)*10)
		bottom_animals.append(new_animal)


