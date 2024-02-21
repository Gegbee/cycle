extends Level2D


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	init_dialog("res://Dialog/Main2.txt", Global.export)
	speakers['player'] = $Player.dialog_entity
	speakers['king'] = $KingNPC.dialog_entity
	$KingNPC.base_convos = [['king1']]
	$KingNPC.activate_base_convo()
	
func _process(delta):
	if $Player.get_node("NoRotation").global_position.x < -850:
		if is_instance_valid(Global.scene_controller):
			Global.scene_controller.call_deferred("switch_scene", "Main", 1.0, 1.0, "pinhole")
