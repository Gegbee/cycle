extends Level2D

@onready var label = $CanvasLayer/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	init_dialog("res://Dialog/Main.txt", Global.export)
	speakers['player'] = $Player.dialog_entity
	speakers['cf'] = $CfNPC.dialog_entity
	$CfNPC.base_convos = [['cf-1', 'cf-2']]

func _process(delta):
	label.text = str(int(-$Player.get_node("NoRotation/Center").global_position.y / 50)) + "m / " + str(int(4500/50)) + "m"


