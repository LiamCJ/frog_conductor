extends Node2D
@onready var label: Label = $Node2D/Label

var value:int = 0:
	set(val):
		value = val
		label.text = str(value)


func _ready() -> void:
	value = 0
