extends CanvasLayer

@onready var reed: Sprite2D = $Control/meter/reed
@onready var score: Label = $Control/currency/acorn/score
@onready var final_score: Label = $EndControl/FinalScore
@onready var end_control: Control = $EndControl
@onready var game_over: Label = $EndControl/GameOver

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	end_control.hide()


func set_morality(val:int)->void:
	reed.rotation = float(val)/50 * PI/2

func set_score(val:int)->void:
	score.text = str(val)

func end_screen_show(text:String)->void:
	end_control.show()
	game_over.text = text
	final_score.text = "Score: " + score.text

func end_screen_hide()->void:
	end_control.hide()
	
	
