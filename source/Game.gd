extends Node2D

onready var HUD = get_node("HUD")

var level_path = ["res://source/levels/Level0.tscn",
						"res://source/levels/Level1.tscn",
						"res://source/levels/Level2.tscn",
						"res://source/levels/Level3.tscn",
						"res://source/levels/Level4.tscn",
						"res://source/levels/Level5.tscn",
						"res://source/levels/Level6.tscn",
						"res://source/levels/Level7.tscn",
						"res://source/levels/Level8.tscn"]

var player
var level_scn
var level

func _ready():
	load_scene()

func load_scene():
	level_scn = load(level_path[Global.current_level])
	level = level_scn.instance()
	add_child(level)
	player = level.get_node("Player")

func exit_scene():
	if Global.current_level < Global.total_levels:
		var duration = 1.0
		yield(get_tree().create_timer(duration), "timeout")
		
		Global.current_level += 1
		
		Global.total_moves += (50 - player.moves)
		Global.total_pumpkins += player.pumpkins
		Global.total_alerts += player.num_alert
		
		HUD.get_node("Results/VBox/TotalMoves").set_text("Total moves: " + str(Global.total_moves))
		HUD.get_node("Results/VBox/TotalPumpkins").set_text("Total pumpkins caught: " + str(Global.total_pumpkins))
		HUD.get_node("Results/VBox/TotalAlerts").set_text("Total alerts: " + str(Global.total_alerts))
		HUD.get_node("Results").set_visible(true)
	else:
		var duration = 1.0
		yield(get_tree().create_timer(duration), "timeout")

		Global.total_moves += (50 - player.moves)
		Global.total_pumpkins += player.pumpkins
		Global.total_alerts += player.num_alert
		
		HUD.get_node("Win/VBox/TotalMoves").set_text("Total moves: " + str(Global.total_moves))
		HUD.get_node("Win/VBox/TotalPumpkins").set_text("Total pumpkins caught: " + str(Global.total_pumpkins))
		HUD.get_node("Win/VBox/TotalAlerts").set_text("Total alerts: " + str(Global.total_alerts))
		
		var pumpkin_score = 225
		var move_deduction = 3
		var alert_deduction = 3000
		var score = (Global.total_pumpkins * pumpkin_score) - (Global.total_moves * move_deduction) - (Global.total_alerts * alert_deduction)
		HUD.get_node("Win/VBox/TotalScore").set_text("Score: " + str(score))
		
		HUD.get_node("Win").set_visible(true)

func lose():
	var duration = 1.0
	yield(get_tree().create_timer(duration), "timeout")
	
	HUD.get_node("Lose/VBox/TotalMoves").set_text("Total moves: " + str(Global.total_moves))
	HUD.get_node("Lose/VBox/TotalPumpkins").set_text("Total pumpkins caught: " + str(Global.total_pumpkins))
	HUD.get_node("Lose/VBox/TotalAlerts").set_text("Total alerts: " + str(Global.total_alerts))
	HUD.get_node("Lose").set_visible(true)

func continue_button_up():
	HUD.get_node("Results").set_visible(false)
	level.queue_free()
	load_scene()
	
	var duration = 0.01
	yield(get_tree().create_timer(duration), "timeout")
	level.get_node("Day'n'Night").set_color(Color("3f316e"))

func try_again_button_up():
	HUD.get_node("Win").set_visible(false)
	
	Global.current_level = 0
	Global.total_moves = 0
	Global.total_pumpkins = 0
	Global.total_alerts = 0
	
	level.queue_free()
	load_scene()
	
	var duration = 0.01
	yield(get_tree().create_timer(duration), "timeout")
	level.get_node("Day'n'Night").set_color(Color("3f316e"))

func restart_level_button_up():
	HUD.get_node("Lose").set_visible(false)
	level.queue_free()
	load_scene()
	
	var duration = 0.01
	yield(get_tree().create_timer(duration), "timeout")
	level.get_node("Day'n'Night").set_color(Color("3f316e"))

func restart_all_button_up():
	HUD.get_node("Lose").set_visible(false)
	level.queue_free()
	
	Global.current_level = 0
	Global.total_moves = 0
	Global.total_pumpkins = 0
	Global.total_alerts = 0
	load_scene()
	
	var duration = 0.01
	yield(get_tree().create_timer(duration), "timeout")
	level.get_node("Day'n'Night").set_color(Color("3f316e"))
