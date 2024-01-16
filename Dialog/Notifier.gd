extends Node2D

var tween: Tween
var notifying : bool = false
@onready var anima = $AnimatedSprite2D
var transition_to : String = ""
var previous_trans_speed : float = 0.0
var current_noti : String = "null"

func _ready():
	show()
	anima.scale = Vector2(0, 0)
	anima.animation = "null"
	
func noti(noti_name, speed = 0.0):
	if noti_name == current_noti:
		return
	current_noti = noti_name
	if noti_name == "null":
		if speed != 0.0:
			if is_instance_valid(tween):
				tween.kill()
			tween = create_tween()
			if is_instance_valid(tween):
				transition_to = ""
				tween.connect("finished",Callable(self,"tween_finished"))
				tween.tween_property(anima, "scale", Vector2(0, 0), speed).from_current()
		else:
			anima.scale = Vector2(0, 0)
		return
	if anima.animation == "null":
		anima.play(noti_name)
		if speed != 0.0:
			if is_instance_valid(tween):
				tween.kill()
			tween = create_tween()
			if is_instance_valid(tween):
				transition_to = ""
				tween.connect("finished",Callable(self,"tween_finished"))
				tween.tween_property(anima, "scale", Vector2(1, 1), speed).from_current()
		else:
			anima.scale = Vector2(1, 1)
	else:
		if speed != 0.0:
			if is_instance_valid(tween):
				tween.kill()
			tween = create_tween()
			if is_instance_valid(tween):
				transition_to = noti_name
				previous_trans_speed = speed
				tween.connect("finished",Callable(self,"tween_finished"))
				tween.tween_property(anima, "scale", Vector2(0, 0), speed).from_current()
		else:
			anima.scale = Vector2(1, 1)
			anima.play(noti_name)
			
func is_notifying():
	return true if anima.scale.length() == 0 else false

func tween_finished():
	if !is_notifying():
		if transition_to == "":
			anima.play("null")
		else:
			tween = create_tween()
			tween.tween_property(anima, "scale", Vector2(1, 1), previous_trans_speed).from(Vector2(0, 0))
			anima.play(transition_to)
			transition_to = ""
	else:
		pass
