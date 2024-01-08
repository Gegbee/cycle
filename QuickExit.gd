extends Node


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _process(_delta):
	if Input.is_action_just_pressed("qe") and !Global.export:
		get_tree().quit()
	if Input.is_action_just_pressed("qr") and !Global.export:
		get_tree().reload_current_scene()
