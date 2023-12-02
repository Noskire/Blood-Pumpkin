extends Node2D

onready var tween = get_node("Tween")
onready var anim = get_node("AnimationPlayer")

export var pos = Vector2(1, 1)
var size = 64
var target

func _ready():
	var final_position = pos * size + Vector2(size / 2, size / 2)
	var duration = 1.5
	
	tween.interpolate_property(self, "position",
		position, final_position, duration,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	anim.play("Moving")
	
	yield(get_tree().create_timer(duration), "timeout")
	anim.play("Idle")

func fly_away():
	var diff = Vector2(0, 0)
	
	if target.pos.x < pos.x:
		diff += Vector2(1, 0)
	elif target.pos.x > pos.x:
		diff += Vector2(-1, 0)
		self.set_scale(Vector2(-1, 1))
	
	if target.pos.y < pos.y:
		diff += Vector2(0, 1)
	elif target.pos.y > pos.y:
		diff += Vector2(0, -1)
	
	var max_dist = Vector2(1024, 640)
	var final_position = diff * max_dist
	var distance = abs(final_position.x) + abs(final_position.y)
	var duration
	if distance == 640:
		duration = 1.5
	elif distance == 1024:
		duration = 2.5
	else:
		duration = 3.5
	
	tween.interpolate_property(self, "position",
		position, (position + final_position), duration,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	anim.play("Moving")
	
	yield(get_tree().create_timer(duration), "timeout")
	out_screen()

func out_screen():
	queue_free()

func _on_Area2D_area_entered(area):
	target = area.get_parent()
	get_node("Area2D/CollisionShape2D").call_deferred("set", "disabled", true)
	
	if target.has_method("distracted"): # Enemy
		target.distracted()
		fly_away()
	elif target.has_method("scare_crow"): # ScareCrow
		pos = (position - Vector2(size / 2, size / 2)) / size
		tween.stop_all()
		anim.play("Scared")
	else: # Player
		fly_away()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Scared":
		fly_away()
	elif not target == null:
		anim.play("Moving")
