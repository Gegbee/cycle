extends Level2D


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	init_dialog("res://Dialog/Main.txt", Global.export)
	speakers['player'] = $Player.dialog_entity
	speakers['mb'] = $MbNPC.dialog_entity
	speakers['mb2'] = $MbNPC2.dialog_entity
	$MbNPC.base_convos = [['mb-1', 'mb-2']]
	$MbNPC.activate_base_convo()
	
func _process(delta):
	if $Player.get_node("NoRotation").global_position.y > 10000:
		if is_instance_valid(Global.scene_controller):
			Global.scene_controller.call_deferred("switch_scene", "Main", 1.0, 1.0, "pinhole")
