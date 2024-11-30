extends Area2D

@export var morality_on_kill:int
@export var morality_on_save:int
@export var speed_modifier:int
@export var proffesion:int
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var coin: Node2D = $Coin

func kill()->void:
	animated_sprite.animation = 'dead'
	animated_sprite.play()

func set_value(val:int)->void:
	coin.value = val
