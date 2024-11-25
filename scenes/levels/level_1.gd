extends Node2D

var speed:int = 100
@onready var path_follow_2d:PathFollow2D = $tram_paths/Path2D/PathFollow2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta:float) -> void:
	var len:float = $tram_paths/Path2D.curve.get_baked_length()
	path_follow_2d.progress_ratio += 0.01 # (speed * delta)/len
	print(path_follow_2d.position)
	$Tram2.position = path_follow_2d.position

	
