extends Node2D

@export var level:Node2D
@export var levels: Array[PackedScene]
@export var start_level: PackedScene
@onready var tram_controller: Node = $TramController
@export var animals: Array[PackedScene]
var top_animals: Array[Area2D]
var bottom_animals: Array[Area2D]
@export var Coin:PackedScene
@onready var camera: Camera2D = $TramController/Tram/Camera2D
@onready var hud: CanvasLayer = $TramController/Tram/HUD

#player properties
var score:int = 0
var morality:int = 0:
	set(val):
		morality = clamp(val,-50,50)
var speed_multiplier: float
var morality_multiplier:float


var num_stops:int = 5
var level_num: int = 0
var top_path_chosen:bool
var paused:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_scene(start_level)
	tram_controller.update_tram = true
	level.train_stop.area_entered.connect(end_screen)

#input
func _input(event: InputEvent) -> void:
		if event.is_action_pressed("switch_tracks"):
			if paused:
				reset()
				tram_controller.update_tram = true
				paused = false
				hud.end_screen_hide()
			else:
				tram_controller.toggle_switch()
	
func end_screen(tram:Area2D)->void:
	tram_controller.update_tram = false
	paused = true
	if level_num == 0:
		hud.end_screen_show('Press space to start')
	else:
		hud.end_screen_show('End of the line')

func reset()->void:
	tram_controller.speed = tram_controller.start_speed
	level_num = 0
	morality = 0
	score = 0
	hud.set_morality(0)
	hud.set_score(0)


func load_scene(lvl:PackedScene)->void:
	if level != null:
		level.queue_free()
	level = lvl.instantiate()
	tram_controller.level = level
	add_child(level)
	camera.limit_left = level.left_end.position.x
	camera.limit_right = level.right_end.position.x
	tram_controller.init_network()
	
func load_next_level()-> void:
	if level_num == num_stops:
		load_scene(start_level)
		level.train_stop.area_entered.connect(end_screen)
	else:
		var rand_lvl:PackedScene = levels.pick_random()
		level_num += 1
		load_scene(rand_lvl)
		spawn_animals()
	tram_controller.update_tram = true
	
func on_animal_hit(animal:Area2D) ->void:
	animal.kill()
	morality += animal.morality_on_kill
	update_hud()
	if animal == top_animals[0]: 
		#if last animal stop tram and board animals
		top_path_chosen = true
		tram_controller.speed = 0
		move_animals_to_tram()
	elif animal == bottom_animals[0]:
		#if last animal stop tram and board animals
		top_path_chosen = false
		tram_controller.speed = 0
		move_animals_to_tram()

func move_animals_to_tram()->void:
	var markers: Array[Marker2D]
	var animals_to_move: Array[Area2D]
	var goal_pos: Vector2
	
	#disable collision for animals
	for animal in top_animals:
		animal.set_deferred('monitorable',false)
	for animal in bottom_animals:
		animal.set_deferred('monitorable',false)
	
	if top_path_chosen:
		markers =  level.animal_spawns.bottom_path
		animals_to_move = bottom_animals
		#goal_pos = level.animal_spawns.top_path[0].position
	else:
		markers =  level.animal_spawns.top_path
		animals_to_move = top_animals
		#goal_pos = level.animal_spawns.bottom_path[0].position
	goal_pos = tram_controller.tram.door_marker.global_position
	
	for i:int in range(animals_to_move.size()):
		#add waypoints for animal walk path
		animals_to_move[i].add_waypoint(markers[0].position)
		animals_to_move[i].add_waypoint(goal_pos)
		#connect a signal for movement ended
		animals_to_move[i].movement_ended.connect(add_to_tram)

func add_to_tram(animal:Area2D)->void:
	tram_controller.max_speed += animal.speed_modifier
	score += animal.coin.value * (1 + morality_multiplier + speed_multiplier)
	morality += animal.morality_on_save
	update_hud()
	animal.queue_free()
	if animal == top_animals[-1] or animal == bottom_animals[-1]:
		tram_controller.speed = tram_controller.max_speed
		morality_multiplier =  float(morality)/200
		speed_multiplier =  (tram_controller.speed - tram_controller.start_speed)/200
	
func update_hud()->void:
	hud.set_morality(morality)
	hud.set_score(score)

func spawn_animal_row(markers:Array[Marker2D],amount:int)->Array[Area2D]:	
	var _animals: Array[Area2D] = []
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

