extends Sprite2D

func up()->void:
	#rotation = 0
	frame = 0
	
func down()->void:
	#rotation = PI
	frame = 1
	
func right()->void:
	rotation = PI/2

func left()->void:
	rotation = -PI/2
