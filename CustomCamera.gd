extends Camera2D


var init_pos : Vector2 = Vector2()
func _ready():
	init_pos = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_instance_valid(Global.player):
		global_position.y = 1500 * int(Global.player.get_node("NoRotation/Center").global_position.y / 1500) + init_pos.y
		#global_position.y = Global.player.get_node("NoRotation").global_position.y + init_pos.y
