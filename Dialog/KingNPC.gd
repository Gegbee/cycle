extends NPC2D


# Called when the node enters the scene tree for the first time.
func _ready():
	dialog_entity.connect("text_step", Callable(self, "on_text_step"))
	super()

func on_text_step():
	$AnimationPlayer.play('Bob')
