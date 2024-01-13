extends CanvasLayer

var focused
@onready var Button3 = $Control/MarginContainer/VBoxContainer/VBoxContainer/Button3
@onready var Button4 = $Control/MarginContainer/VBoxContainer/VBoxContainer/Button4

func _ready():
	visible = false
	get_viewport().connect("gui_focus_changed", Callable(self, "_on_focus_changed"))

func _on_focus_changed(control:Control): focused = control

func _process(delta):
	if Music.min == 0 and focused != Button3: 
		Music.min = 600 
		Music.lowpass.cutoff_hz = 600
		Button3.get_child(0).stop()
	if !get_tree().paused:
		Button3.get_child(0).stop()
		Global.elapsed_time += delta
		
	$Control/MarginContainer/VBoxContainer/Label2.text = "Time played: " + str(roundf(Global.elapsed_time)) + " seconds"

func _input(event):
	if event.is_action_pressed('escape'):
		Music.lowpass.cutoff_hz = clamp(Music.lowpass.cutoff_hz, 600, 30000)
		toggle_pause()
	
	#there is prob a better way to do this if u wanna reorganize it
	if visible:
		if event.is_action_pressed("left"):
			if focused == Button3:
				Music.min = 0
				if not Button3.get_child(0).playing: Button3.get_child(0).play()
				Global.MUS_vol = clamp(Global.MUS_vol - 1, 0, 10)
				Button3.text = "\nMusic: " + str(Global.MUS_vol)
				Music.update_bus_volume()
				
			if focused == Button4:
				var sound = Button4.get_children().pick_random()
				sound.pitch_scale = randf_range(0.9, 1.1)
				sound.play()
				Global.SFX_vol = clamp(Global.SFX_vol - 1, 0, 10)
				Button4.text = "SFX: " + str(Global.SFX_vol)
				Music.update_bus_volume()
				
		elif event.is_action_pressed("right"):
			if focused == Button3:
				Music.min = 0
				if not Button3.get_child(0).playing: Button3.get_child(0).play()
				Global.MUS_vol = clamp(Global.MUS_vol + 1, 0, 10)
				Button3.text = "\nMusic: " + str(Global.MUS_vol)
				Music.update_bus_volume()
				
			if focused == Button4:
				var sound = Button4.get_children().pick_random()
				sound.pitch_scale = randf_range(0.9, 1.1)
				sound.play()
				Global.SFX_vol = clamp(Global.SFX_vol + 1, 0, 10)
				Button4.text = "SFX: " + str(Global.SFX_vol)
				Music.update_bus_volume()
				
		elif event.is_action_pressed("accept"):
			if focused == Button3:
				Music.min = 0
				if not Button3.get_child(0).playing: Button3.get_child(0).play()
				Global.MUS_vol += 1
				if Global.MUS_vol > 10: Global.MUS_vol = 0
				Button3.text = "\nMusic: " + str(Global.MUS_vol)
				Music.update_bus_volume()
				
			if focused == Button4:
				var sound = Button4.get_children().pick_random()
				sound.pitch_scale = randf_range(0.9, 1.1)
				sound.play()
				Global.SFX_vol += 1
				if Global.SFX_vol > 10: Global.SFX_vol = 0
				Button4.text = "SFX: " + str(Global.SFX_vol)
				Music.update_bus_volume()

func toggle_pause():
	visible = !visible
	get_tree().paused = visible
	Music.lowpass_on = visible
	if visible:
		$Control/MarginContainer/VBoxContainer/VBoxContainer/Button.grab_focus()
		
func _on_button_button_down():
	if get_tree().get_current_scene().is_in_group('controller'):
		get_tree().get_current_scene().call_deferred("switch_scene", 'SplashMenu', 2.0, 2.0)
		toggle_pause()
	else:
		print('not in controller')

func _on_button_2_button_down():
	get_tree().quit()


func _on_h_slider_toggled(button_pressed):
	pass
	#Global.set_accessible(button_pressed)
		
