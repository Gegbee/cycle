extends Node2D

@onready var dialog_entity = DialogEntity.new($NoRotation/DialogBubble/RichTextLabel, $NoRotation/DialogBubble/Choices, $NoRotation/DialogBubble)

@onready var body = $Body
@onready var wheel = $Wheel
const LEAN_POWER := 700.0
var jump_cooldown : float = 0.0
var jump_mult : float = 0.0
const INIT_JUMP_SPEED = 16000
const JUMP_CHARGE_TIME := 0.5

enum {
	ACTIVE,
	DISABLED
}
var state := ACTIVE

var npc_input_need : DialogEntity = null
var choice_input_need : bool = false
var npcs_in_range : Array = []

var body_pid = PID.new(70000.0, 0.0, 10000.0, 0.0)
var init_wheel_rot := 0.0
var wheel_pid = PID.new(70000.0, 0.0, 2000.0, 0.0)
var wheelt_pid = PID.new(7000.0, 0.0, 100.0, 0.0)
var mouse_vel : Vector2 = Vector2()
var target_player_rot : float = 0.0
var body_rot_pid = PID.new(7000.0, 0.0, 0.0, 0.0)
var wheel_vel_to_lean_ratio : float = 80

var keys : bool = false

var prev_vel : Vector2 = Vector2()
var cur_vel : Vector2 = Vector2()
var blink_timer = 0.0
const BLINK_TIME : float = 2.6

@onready var fish_tail = $Body/FishTail
@onready var fish_body = $Body/FishBody
@onready var eye = $Body/Eye
@onready var pedal_1 = $Pedal1
@onready var pedal_2 = $Pedal2

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(dialog_entity)
	Global.player = self
	#await get_tree().create_timer(1.0).timeout
	#set_state(DISABLED)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$NoRotation.global_position = $Wheel.global_position
	$Body/Sprite2D.position.y = -144 + jump_mult * 10
	$Body/Sprite2D.scale.y = 1.0 - 0.1*jump_mult
	#fish_tail.position = lerpf()
	if blink_timer >= BLINK_TIME:
		eye.play("blink")
		blink_timer = 0.0
	else:
		blink_timer += delta
		
	if state != ACTIVE:
		autobalance(delta)
		return
	pedal_1.global_position = $Wheel/Pedal1.global_position
	pedal_2.global_position = $Wheel/Pedal2.global_position
	#if (prev_vel - cur_vel).length() > 20:
	#	eye.play("squint")
	#prev_vel = cur_vel
	#cur_vel = body.linear_velocity
	
	var horz1 = Input.get_action_strength("right") - Input.get_action_strength("left")
	if keys:
		mouse_vel.x = horz1 * 20
	#if wheel.is_on_floor:
	#	body.apply_impulse(Vector2(-horz1 * delta * LEAN_POWER, 0), Vector2(0, -250))
	#else:
	#	body.apply_impulse(Vector2(-horz1 * delta * LEAN_POWER / 2, 0), Vector2(0, -250))
	#var horz2 = Input.get_action_strength("right2") - Input.get_action_strength("left2")
	#wheel.apply_torque_impulse(horz2 * 50000 * delta)
	if abs(body.rotation) < PI/3 and wheel.is_on_floor:
		wheel.apply_torque_impulse(-wheelt_pid.step(wheel.angular_velocity - wheel_vel_to_lean_ratio * fmod(body.rotation, 2 * PI)/(PI/3), delta) * delta)
		#print(wheel.angular_velocity, ", ", fmod(body.rotation, 2 * PI)/(PI/3))
	#else:
		#wheel.apply_torque_impulse(wheel_pid.step(-wheel.rotation, delta) * delta)
	if wheel.is_on_floor:
		#body.apply_force(Vector2(body_pid.step(target_player_rot-body.rotation, delta) * delta, 0), Vector2(0, -250))
		body.apply_impulse(Vector2(mouse_vel.x * 100/2/35.0 * Global.sense, 0), Vector2(0, -250))
	else:
		body.apply_central_impulse(Vector2(mouse_vel.x * 50/50.0 * Global.sense, 0))
		body.apply_impulse(Vector2(mouse_vel.x * 30/35.0 * Global.sense, 0), Vector2(0, -250))
	if (Input.is_action_just_released("jump")) and jump_mult > 0 and jump_cooldown <= 0.0 and wheel.is_on_floor:
			jump_cooldown = 0.2
			#linear_velocity.y = 0
			#linear_velocity.y -= INIT_JUMP_SPEED * (jump_mult*3/4 + 0.25)
			body.apply_central_impulse(Vector2.UP.rotated(fmod(body.rotation, 2 * PI)) * INIT_JUMP_SPEED * (jump_mult*3/4 + 0.25))
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

func autobalance(delta):
	body.apply_force(Vector2(body_pid.step(-fmod(body.rotation, 2 * PI), delta) * delta, 0), Vector2(0, -250))
	wheel.apply_torque_impulse(wheel_pid.step(init_wheel_rot - wheel.rotation, delta) * delta * 50)
	
func set_state(_state : int):
	if _state == ACTIVE:
		state = _state
		# turn off autobalancing, should be stable anyways so won't move until player touches? 
		# Would not work on slopes, would just have to sleep player maybe or nothing at all
		pass
	elif _state == DISABLED:
		state = _state
		# autobalance if not already on the ground
		init_wheel_rot = wheel.rotation
		pass

func _input(event):
	if event is InputEventMouseMotion and !keys:
		mouse_vel = event.relative
		if abs(mouse_vel.x) < 1:
			mouse_vel.x = 0
		target_player_rot = clamp(mouse_vel.x, -40, 40)
		#print(target_player_rot)
		#mouse_vel.x = clamp(mouse_vel.x, -1, 1)
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


func _on_eye_animation_finished():
	if eye.animation == "blink":
		eye.play("open")
