extends Node2D

onready var tilemap = get_parent().get_parent().get_node("TileMap")
onready var player = get_parent().get_parent().get_node("Player")
onready var view = get_node("View")
onready var area2d = get_node("Area2D")
onready var exclamation = get_node("!")

onready var enemies_node = get_parent().get_children()

export var pos = Vector2(1, 1)
export var rect = Rect2(Vector2(2,2), Vector2(11,5))
export var dir = "right"
export var type = "rect" #"straight line" or "round" or "rect"

var size = 64

var seeing_player = false
var got_distracted = false
var distracted_duration = 3
var distracted_turn = 0

func _ready():
	position = pos * size + Vector2(size / 2, size / 2)
	if dir == "left":
		self.set_scale(Vector2(-1, 1))

func hunt():
	var diff = Vector2(0, 0)
	
	if player.pos.x < pos.x:
		diff += Vector2(-1, 0)
		self.set_scale(Vector2(-1, 1))
	elif player.pos.x > pos.x:
		diff += Vector2(1, 0)
		self.set_scale(Vector2(1, 1))
	
	if player.pos.y < pos.y:
		diff += Vector2(0, -1)
		view.set_rotation_degrees(270)
		area2d.set_rotation_degrees(270)
		
	elif player.pos.y > pos.y:
		diff += Vector2(0, 1)
		view.set_rotation_degrees(90)
		area2d.set_rotation_degrees(90)
	else:
		view.set_rotation_degrees(0)
		area2d.set_rotation_degrees(0)
	
	pos += diff
	if player.pos == pos:
		player.hit_by_enemy()
	
	position += diff * size

func move_enemy():
	if got_distracted:
		distracted_turn += 1
		if distracted_turn == distracted_duration:
			got_distracted = false
			exclamation.set_visible(false)
	elif seeing_player:
		hunt()
	else:
		var diff
		if dir == "left":
			diff = - Vector2(1, 0)
			self.set_scale(Vector2(-1, 1))
			view.set_rotation_degrees(0)
			area2d.set_rotation_degrees(0)
		elif dir == "right":
			diff = Vector2(1, 0)
			self.set_scale(Vector2(1, 1))
			view.set_rotation_degrees(0)
			area2d.set_rotation_degrees(0)
		elif dir == "up":
			diff = - Vector2(0, 1)
			view.set_rotation_degrees(270)
			area2d.set_rotation_degrees(270)
		elif dir == "down":
			diff = Vector2(0, 1)
			view.set_rotation_degrees(90)
			area2d.set_rotation_degrees(90)
		
		if tilemap.get_cellv(pos + diff) == 0:
			if type == "rect":
				if pos_inside_rect(pos + diff):
					pos += diff
					if player.pos == pos:
						player.hit_by_enemy()
					
					position += diff * size
				else:
					invert_dir()
			else:
				pos += diff
				if player.pos == pos:
					player.hit_by_enemy()
				
				position += diff * size
		else:
			invert_dir()

func pos_inside_rect(new_pos):
	if new_pos.x >= rect.position.x and new_pos.x <= rect.end.x and new_pos.y >= rect.position.y and new_pos.y <= rect.end.y:
		return true
	else:
		return false

func invert_dir():
	if type == "straight line":
		if dir == "left":
			dir = "right"
		elif dir == "right":
			dir = "left"
		elif dir == "up":
			dir = "down"
		elif dir == "down":
			dir = "up"
	elif type == "round":
		var diff
		if dir == "left":
			diff = Vector2(0, 1)
			if tilemap.get_cellv(pos + diff) == 0:
				dir = "down"
			else:
				dir = "up"
		elif dir == "down":
			diff = Vector2(1, 0)
			if tilemap.get_cellv(pos + diff) == 0:
				dir = "right"
			else:
				dir = "left"
		elif dir == "right":
			diff = - Vector2(0, 1)
			if tilemap.get_cellv(pos + diff) == 0:
				dir = "up"
			else:
				dir = "down"
		elif dir == "up":
			diff = - Vector2(1, 0)
			if tilemap.get_cellv(pos + diff) == 0:
				dir = "left"
			else:
				dir = "right"
	elif type == "rect":
		if dir == "right":
			dir = "down"
		elif dir == "down":
			dir = "left"
		elif dir == "left":
			dir = "up"
		elif dir == "up":
			dir = "right"

func distracted():
	#print("distracted")
	distracted_turn = 0
	got_distracted = true
	exclamation.set_visible(true)

func _on_Area2D_area_entered(area):
	if area.get_parent().has_method("fly_away"):
		pass
	else: # player
		area.get_parent().alert()
		#get_node("Area2D/CollisionPolygon2D").call_deferred("set", "disabled", true)
		#print("On the hunt!")
		for e in enemies_node:
			e.seeing_player = true
			e.exclamation.set_visible(true)
			e.get_node("Area2D/CollisionPolygon2D").call_deferred("set", "disabled", true)
