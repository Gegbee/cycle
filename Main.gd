extends Level2D


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	init_dialog("res://Dialog/Main.txt", Global.export)
	speakers['player'] = $Player.dialog_entity
	speakers['cf'] = $CfNPC.dialog_entity
	$CfNPC.base_convos = [['cf-1', 'cf-2']]
