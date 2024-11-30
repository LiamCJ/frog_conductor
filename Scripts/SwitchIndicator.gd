extends Sprite2D

func up()->void:
	rotation = 0
	
func down()->void:
	rotation = PI
	
func right()->void:
	rotation = PI/2

func left()->void:
	rotation = -PI/2
