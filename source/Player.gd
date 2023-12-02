extends Node2D

onready var game = get_parent().get_parent()
onready var tilemap = get_parent().get_node("TileMap")
onready var enemies_node = get_parent().get_node("Enemies").get_children()
onready var pumpkins_node = get_parent().get_node("Pumpkins").get_children()
onready var exit_node = get_parent().get_node("Exit")
onready var HUD_moves_left = get_parent().get_parent().get_node("HUD/Control/HBox/MovesLeft")
onready var HUD_pumpkins_caught = get_parent().get_parent().get_node("HUD/Control/HBox/PumpkinsCaught")
onready var HUD_alert = get_parent().get_parent().get_node("HUD/Control/HBox/Alert")
onready var DaynNight = get_parent().get_node("Day'n'Night")

onready var tween = get_node("Tween")
onready var anim = get_node("AnimationPlayer")
onready var fire_path = "res://source/Fire.tscn"

export var pos = Vector2(1, 8)
export var moves = 50

var turn_stage = "waiting input"
var input
var pumpkins = 0
var num_alert = 0
var size = 64

func _ready():
	position = pos * size + Vector2(size / 2, size / 2)
	HUD_moves_left.set_text("Moves Left: " + str(moves))
	HUD_pumpkins_caught.set_text("Pumpkins Caught: " + str(pumpkins))
	HUD_alert.set_text("Alert: " + str(num_alert))

func move_player():
	var diff
	if input == "left":
		diff = - Vector2(1, 0)
	elif input == "right":
		diff = Vector2(1, 0)
	elif input == "up":
		diff = - Vector2(0, 1)
	elif input == "down":
		diff = Vector2(0, 1)
	
	if tilemap.get_cellv(pos + diff) == 0:
		pos += diff
		for e in enemies_node:
			if e.pos == pos:
				#print("Player hit enemy")
				pass
		for p in pumpkins_node:
			if p.pos == pos:
				#print("Get a pumpkin")
				pumpkins += 1
				HUD_pumpkins_caught.set_text("Pumpkins Caught: " + str(pumpkins))
				pumpkins_node.erase(p)
				p.got()
				break
		if exit_node.pos == pos:
			#print("Exiting level")
			turn_stage = "exiting level"
		
		var duration = 0.12
		tween.interpolate_property(self, "position",
			position, (position + diff * size), duration,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		anim.play("Moving")
		
		yield(get_tree().create_timer(duration), "timeout")
		anim.play("Idle")
		
		#position += diff * size
		end_turn()
	else:
		#print("Can't move")
		turn_stage = "waiting input"

func end_turn():
	moves -= 1
	HUD_moves_left.set_text("Moves Left: " + str(moves))
	DaynNight.pass_time()
	
	for e in enemies_node:
		e.move_enemy()
	
	if turn_stage == "exiting level":
		anim.play("Success")
		if pumpkins == 1:
			#print("You got " + str(pumpkins) + " pumpkin!")
			pass
		else:
			#print("You got " + str(pumpkins) + " pumpkins!")
			pass
		game.exit_scene()
	elif moves == 0 or turn_stage == "Hit by enemy":
		if moves == 0:
			var fire_scn = load(fire_path)
			var fire = fire_scn.instance()
			add_child(fire)
		anim.play("Dying")
		#print("You lose!")
		turn_stage = "Game Over"
		game.lose()
	else:
		turn_stage = "waiting input"

func hit_by_enemy():
	#print("Enemy hit player")
	turn_stage = "Hit by enemy"

func alert():
	num_alert += 1
	HUD_alert.set_text("Alert: " + str(num_alert))

func _process(_delta):
	if turn_stage == "processing input":
		turn_stage = "move"
		move_player()

func _input(event):
	if turn_stage == "waiting input":
		if event.is_action_pressed("ui_left"):
			input = "left"
			turn_stage = "processing input"
			self.set_scale(Vector2(-1, 1))
		elif event.is_action_pressed("ui_right"):
			input = "right"
			turn_stage = "processing input"
			self.set_scale(Vector2(1, 1))
		elif event.is_action_pressed("ui_up"):
			input = "up"
			turn_stage = "processing input"
		elif event.is_action_pressed("ui_down"):
			input = "down"
			turn_stage = "processing input"
