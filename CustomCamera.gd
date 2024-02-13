extends Camera2D


var init_pos : Vector2 = Vector2()
func _ready():
	init_pos = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_instance_valid(Global.player):
		global_position.y = 1080 * int(Global.player.get_node("NoRotation/Center").global_position.y / 1080) + init_pos.y
		global_position.x = 1920 * int((Global.player.get_node("NoRotation/Center").global_position.x - 1920/2) / 1920 ) + init_pos.x
