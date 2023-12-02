extends Node2D

export var pos = Vector2(1, 1)
var size = 64

func _ready():
	position = pos * size + Vector2(size / 2, size / 2)

func got():
	queue_free()
