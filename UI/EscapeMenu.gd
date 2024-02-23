extends CanvasLayer

#var focused
#@onready var Button3 = $Control/MarginContainer/VBoxContainer/VBoxContainer/Button3
#@onready var Button4 = $Control/MarginContainer/VBoxContainer/VBoxContainer/Button4

func _ready():
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_viewport().connect("gui_focus_changed", Callable(self, "_on_focus_changed"))

#func _on_focus_changed(control:Control): focused = control

func _process(delta):
	Global.elapsed_time += delta
	$Control/MarginContainer/VBoxContainer/Label2.text = "Time played: " + str(roundf(Global.elapsed_time)) + " s"

func _input(event):
	if event.is_action_pressed('escape'):
		toggle_pause()
	
	#there is prob a better way to do this if u wanna reorganize it

func toggle_pause():
	visible = !visible
	get_tree().paused = visible
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#$Control/MarginContainer/VBoxContainer/VBoxContainer/Button.grab_focus()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
func _on_button_button_down():
	if is_instance_valid(Global.scene_controller):
		Global.scene_controller.call_deferred("switch_scene", 'Splash', 1.0, 1.0, "pinhole")
		toggle_pause()
	else:
		print('not in controller')

func _on_button_2_button_down():
	get_tree().quit()


func _on_h_slider_toggled(button_pressed):
	pass
	#Global.set_accessible(button_pressed)
		


func _on_h_slider_value_changed(value):
	Global.sense = value/100.0 + 0.5


func _on_vol_slider_value_changed(value):
	Global.volume = value/100.0


func _on_option_button_item_selected(index):
	if index == 0:
		Global.fps = 0
	elif index == 1:
		Global.fps = 30
	elif index == 2:
		Global.fps = 60
	Engine.max_fps = Global.fps
	
