extends Area2D

signal movement_ended(animal:Area2D)

@export var morality_on_kill:int
@export var morality_on_save:int
@export var speed_modifier:int
@export var proffesion:int
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var coin: Node2D = $Coin

var speed: int = 40
var goal_pos: Vector2
var waypoints: Array[Vector2]

var dead:bool = false

func _ready() -> void:
	goal_pos = position

func kill()->void:
	dead = true
	animated_sprite.animation = 'dead'
	animated_sprite.play()
	coin.queue_free()
	$AudioStreamPlayer.play()

func set_value(val:int)->void:
	coin.value = val

func animate_to(pos:Vector2)->void:
	goal_pos = pos

func add_waypoint(pos:Vector2) ->void:
	if pos != position:
		waypoints.append(pos)
		goal_pos = waypoints[0]

func update_pos(delta:float)->void:
	var direction:Vector2 =  (goal_pos - position)
	animated_sprite.animation = 'walk'
	animated_sprite.play()
	if direction.length() < speed * delta:
		position = goal_pos
		#goal pos reached
		waypoints.pop_front()
		if waypoints.size() != 0:
			goal_pos = waypoints[0]
		else:
			movement_ended.emit(self)
	else:
		position += direction.normalized() * speed * delta


func _process(delta: float) -> void:
	if position != goal_pos:
		update_pos(delta)
	elif not dead:
		animated_sprite.animation = 'idle'
