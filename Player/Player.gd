extends Node2D

@onready var dialog_entity = DialogEntity.new($DialogBubble/RichTextLabel, $DialogBubble/Choices, $DialogBubble)

@onready var body = $RigidBody2D2
@onready var wheel = $RigidBody2D
const LEAN_POWER := 800.0
var jump_cooldown : float = 0.0
var jump_mult : float = 0.0
const INIT_JUMP_SPEED = 1400
const JUMP_CHARGE_TIME := 0.5

enum {
	ACTIVE,
	DISABLED
}

var npc_input_need : DialogEntity = null
var choice_input_need : bool = false
var npcs_in_range : Array = []
# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(dialog_entity)
	Global.player = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var horz1 = Input.get_action_strength("right") - Input.get_action_strength("left")
	if wheel.is_on_floor:
		body.apply_impulse(Vector2(-horz1 * delta * LEAN_POWER, 0), Vector2(0, -250))
		wheel.apply_torque_impulse(horz1 * 5000 * delta)
	else:
		body.apply_impulse(Vector2(-horz1 * delta * LEAN_POWER / 2, 0), Vector2(0, -250))
		wheel.apply_torque_impulse(horz1 * 5000 * delta)
	#var horz2 = Input.get_action_strength("right2") - Input.get_action_strength("left2")
	#wheel.apply_torque_impulse(horz2 * 500000 * delta)
	#if abs(body.rotation) < PI/3:
	#wheel.apply_torque_impulse(body.rotation * 50000 * delta)
	if (Input.is_action_just_released("jump")) and jump_mult > 0 and jump_cooldown <= 0.0 and wheel.is_on_floor:
			jump_cooldown = 0.2
			#linear_velocity.y = 0
			#linear_velocity.y -= INIT_JUMP_SPEED * (jump_mult*3/4 + 0.25)
			wheel.apply_central_impulse(Vector2.UP*INIT_JUMP_SPEED * (jump_mult*3/4 + 0.25))
	if jump_cooldown > 0.0:
		jump_cooldown -= delta
	if wheel.is_on_floor:
		if Input.is_action_pressed("jump"):
			if jump_mult >= 1.0:
				#max_vel = 0  
				pass
			else:
				jump_mult += delta * 1 / JUMP_CHARGE_TIME
				jump_mult = clamp(jump_mult, 0, 1.0)
		else:
			jump_mult = 0

func set_state(state : int):
	if state == ACTIVE:
		# turn off autobalancing, should be stable anyways so won't move until player touches? 
		# Would not work on slopes, would just have to sleep player maybe or nothing at all
		pass
	elif state == DISABLED:
		# autobalance if not already on the ground
		pass

func _input(event):
	if Input.is_action_just_pressed('interact'):
		if npc_input_need != null:
			npc_input_need.process_input()
			return
		if dialog_entity.cur_convo_name != "":
			return
		var npc = null
		for body in npcs_in_range:
			if body is NPC2D:
				if body.is_convo_avail():
					npc = body
		
		if npc and !npc.dialog_entity.is_interact_locked():
			npc.activate_base_convo()
			
	if choice_input_need:
		if Input.is_action_just_pressed("left"):
			dialog_entity.change_choice(false)
		elif Input.is_action_just_pressed("right"):
			dialog_entity.change_choice(true)
			
func disable_notis(yes : bool):
	for body in npcs_in_range:
		if yes:
			body.notify_near(false)
		else:
			body.notify_near(true)

func _on_area_2d_body_entered(body):
	if body is NPC2D:
		body.notify_near(true)
		npcs_in_range.append(body)

func _on_area_2d_body_exited(body):
	if body is NPC2D:
		body.notify_near(false)
		npcs_in_range.erase(body)
