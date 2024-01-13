extends Button



@export var nodepath_below : NodePath
@export var nodepath_above : NodePath

func _ready():
	if nodepath_above:
		focus_neighbor_top = nodepath_above
		focus_previous = nodepath_above
	if nodepath_below:
		focus_neighbor_bottom = nodepath_below
		focus_next = nodepath_below
