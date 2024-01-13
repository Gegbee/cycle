extends Control

var pressed := false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed("accept") and !pressed:
		pressed = true
		if is_instance_valid(Global.scene_controller):
			Global.scene_controller.switch_scene("Main", 1.0, 1.0, "pinhole")
