extends Node2D

export var pos = Vector2(1, 1)
var size = 64

func _ready():
	get_parent().get_node("TileMap").set_cellv(pos, -1)
	position = pos * size + Vector2(size / 2, size / 2)

func scare_crow():
	pass
