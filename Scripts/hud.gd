extends CanvasLayer

@onready var reed: Sprite2D = $Control/meter/reed
@onready var score: Label = $Control/currency/acorn/score
@onready var final_score: Label = $EndControl/FinalScore
@onready var end_control: Control = $EndControl

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	end_control.hide()


func set_morality(val:int)->void:
	reed.rotation = float(val)/50 * PI/2

func set_score(val:int)->void:
	score.text = str(val)
	
