extends Node

var scenes_in_game : Dictionary = {
	"Splash" : preload("res://UI/SplashMenu.tscn"),
	"Intro" : preload("res://Intro.tscn"),
	"Main" : preload("res://Main.tscn"),
}
var cur_scene_name = 3
var cur_scene = null

@onready var screen_fade : ColorRect = $CanvasLayer2/ColorRect
@onready var screen_pinhole : ColorRect = $CanvasLayer/ColorRect
var tween: Tween
var temp_out_time : float = 0.1
var transitioning : bool = false
var trans_type = "pinhole"

func _ready():
	$CanvasLayer2/ColorRect.color = "000000"
	add_to_group('controller')
	call_deferred("switch_scene", "Splash", 0.0, 1.0, "pinhole")
	Global.scene_controller = self
	
var ff := 0.0
func switch_scene(new_scene_name, in_time : float = 0.0, out_time : float = 0.0, _trans_type="none", sound_effect_out = "none", sound_effect_in = "none", full_fade_out : bool = false):
	if !transitioning and scenes_in_game.keys().has(new_scene_name):
		cur_scene_name = new_scene_name
		temp_out_time = out_time
		transitioning = true
		trans_type = _trans_type
		if trans_type == "pinhole":
			tween = create_tween()
			tween.connect("finished",Callable(self,"tween_finished"))
			tween.tween_property(screen_pinhole.get_material(), "shader_parameter/circle_size", -0.2, in_time).from_current()
		elif trans_type == "fade":
			tween = create_tween()
			tween.connect("finished",Callable(self,"tween_finished"))
			tween.tween_property(screen_fade, "color:a", 1.0, in_time).from_current()
		elif trans_type == "none":
			screen_fade.color = Color(0.0, 0.0, 0.0, 1.0)
			fade_out()
	else:
		pass
#		print("Cur scene name does not exist or in transition")


func fade_out():
	if cur_scene != null:
		cur_scene.queue_free()
	cur_scene = scenes_in_game[cur_scene_name].instantiate()
	add_child(cur_scene)
	if trans_type == "pinhole":
		tween = create_tween()
		tween.connect("finished",Callable(self,"tween_finished"))
		tween.tween_property(screen_pinhole.get_material(), "shader_parameter/circle_size", 1.2, temp_out_time).from_current()
	elif trans_type == "fade":
		tween = create_tween()
		tween.connect("finished",Callable(self,"tween_finished"))
		tween.tween_property(screen_fade, "color:a", 0.0, temp_out_time).from_current()
	elif trans_type == "none":
		screen_fade.color = Color(0.0, 0.0, 0.0, 0.0)
		transitioning = false
	temp_out_time = -1.0

func tween_finished():
	if temp_out_time == -1.0:
		transitioning = false
	else:
		$Timer.start(0.5)

func _on_timer_timeout():
	fade_out()
