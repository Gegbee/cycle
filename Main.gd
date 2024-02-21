extends Level2D

@onready var label = $CanvasLayer/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	init_dialog("res://Dialog/Main2.txt", Global.export)
	speakers['player'] = $Player.dialog_entity
	speakers['scroll1'] = $ScrollNPC1.dialog_entity
	speakers['scroll2'] = $ScrollNPC2.dialog_entity
	$ScrollNPC1.base_convos = [['scroll1']]
	$ScrollNPC2.base_convos = [['scroll2']]

func _process(delta):
	label.text = str(int(-$Player.get_node("NoRotation/Center").global_position.y / 100)) + "m / " + str(int(1080*10/100)) + "m"
