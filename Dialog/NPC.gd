extends StaticBody2D
class_name NPC2D

@onready var dialog_entity = DialogEntity.new($DialogBubble/RichTextLabel, $DialogBubble/Choices, $DialogBubble)
@export var static_convo : bool = false

var past_convos : Array = []
var current_convo_set : int = 0
var base_convos : Array = [[]]
var times_talked_to : int = 0

func _ready():
	add_child(dialog_entity)
	dialog_entity.connect("convo_delay_finished", Callable(self, "_on_convo_delay_finished"))

func change_convo_set(new_set_number):
	current_convo_set = new_set_number
	
func activate_base_convo():
	if base_convos[current_convo_set] == []:
		return
	var new_pot_convo = base_convos[current_convo_set][0]
	if is_instance_valid(Global.dialog):
		past_convos.append(new_pot_convo)
		if !static_convo:
			base_convos[current_convo_set].erase(new_pot_convo)
		Global.dialog.start_convo(new_pot_convo)
		times_talked_to += 1
		Global.player.disable_notis(true)
		
func notify_near(near : bool):
	if near:
		if is_convo_avail() and !dialog_entity.is_interact_locked():
			$Notifier.noti("interact", 0.1)
	else:
		$Notifier.noti("null", 0.1)
		
func is_convo_avail() -> bool:
	return true if base_convos[current_convo_set] != [] else false
	
func update_notify():
	if self in Global.player.npcs_in_range:
		if is_convo_avail() and !dialog_entity.is_interact_locked():
			$Notifier.noti("interact", 0.1)
	else:
		$Notifier.noti("null", 0.1)
			
func _on_convo_delay_finished():
	Global.player.disable_notis(false)
