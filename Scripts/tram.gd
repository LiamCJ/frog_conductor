extends Area2D

@onready var straight_animator: AnimatedSprite2D = $straight_animator
@onready var down_animator: AnimatedSprite2D = $down_animator
@onready var up_animator: AnimatedSprite2D = $up_animator
@export var door_marker:Marker2D

func _ready() -> void:
	$TileMap.queue_free()


func up()->void:
	straight_animator.visible = false
	up_animator.visible = true
	down_animator.visible = false

func down()->void:
	straight_animator.visible = false
	up_animator.visible = false
	down_animator.visible = true

func straight()->void:
	straight_animator.visible = true
	up_animator.visible = false
	down_animator.visible = false
