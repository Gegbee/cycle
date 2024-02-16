extends Node2D

@onready var dialog_entity = DialogEntity.new($NoRotation/DialogBubble/RichTextLabel, $NoRotation/DialogBubble/Choices, $NoRotation/DialogBubble)

@export var jump_cooldown_max : float = 0.2
@export var init_jump_speed : float = 16000
@export var jump_charge_time : float = 0.5
@export var max_lean : float = PI/3
@export var wheel_vel_to_lean_ratio : float = 80
@export var air_movement : float = 50/30.0
@export var ground_lean : float = 50/35.0
@export var air_lean : float = 30/35.0

@onready var body = $Body
@onready var wheel = $Wheel
const LEAN_POWER := 700.0
var jump_cooldown : float = 0.0
var jump_mult : float = 0.0

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

var keys : bool = false

var prev_vel : Vector2 = Vector2()
var cur_vel : Vector2 = Vector2()
var blink_timer = 0.0
const BLINK_TIME : float = 2.6

@onready var fish_tail = $Body/Visible/FishTail
@onready var fish_body = $Body/Visible/FishBody
@onready var eye = $Body/Visible/Eye
@onready var pedal_1 = $Pedal1
@onready var pedal_2 = $Pedal2
@onready var joint_1 = $Joint1
@onready var joint_11 = $Joint1/Joint11
@onready var joint_2 = $Joint2
@onready var joint_21 = $Joint2/Joint21

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(dialog_entity)
	Global.player = self
	#await get_tree().create_timer(1.0).timeout
	#set_state(DISABLED)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# COSMETIC
	$NoRotation.global_position = $Wheel.global_position
	$Body/Visible.position.y = jump_mult * 4
	if 1.0 - 0.05*jump_mult > $Body/Visible.scale.y:
		$Body/Visible.scale.y = lerpf($Body/Visible.scale.y, 1.0 - 0.05*jump_mult, 2.0 * delta)
	else:
		$Body/Visible.scale.y = 1.0 - 0.05*jump_mult
	#fish_tail.position = lerpf()
	if blink_timer >= BLINK_TIME:
		eye.play("blink")
		blink_timer = 0.0
	else:
		blink_timer += delta
		
	pedal_1.global_position = $Wheel/Pedal1.global_position
	pedal_2.global_position = $Wheel/Pedal2.global_position
	
	# Distance from Joint0 to Target
	joint_1.global_position = $Body/Visible/Joint1.global_position
	var length0 = (joint_1.global_position - joint_11.global_position).length()
	var length1 = (joint_11.global_position - $Joint1/Joint11/Hand.global_position).length()
	var length2 = (joint_1.global_position - $Wheel/Pedal1.global_position).length()
	# Inner angle alpha
	
	var diff = $Wheel/Pedal1.global_position - joint_1.global_position
	var atan = atan2(diff.y, diff.x) - PI/2
	if length0+length1 < length2:
		joint_1.global_rotation = atan
		joint_11.global_rotation = atan
	else:
		var cosAngle0 = ((length2 * length2) + (length0 * length0) - (length1 * length1)) / (2 * length2 * length0)
		var angle0 = acos(cosAngle0)
		# Inner angle beta
		var cosAngle1 = ((length1 * length1) + (length0 * length0) - (length2 * length2)) / (2 * length1 * length0)
		var angle1 = acos(cosAngle1)

		joint_1.rotation = atan+angle0
		joint_11.rotation = PI + angle1
		
		
	joint_2.global_position = $Body/Visible/Joint2.global_position
	var length0_ = (joint_2.global_position - joint_21.global_position).length()
	var length1_ = (joint_21.global_position - $Joint2/Joint21/Hand.global_position).length()
	var length2_ = (joint_2.global_position - $Wheel/Pedal2.global_position).length()
	# Inner angle alpha
	
	var diff_ = $Wheel/Pedal2.global_position - joint_2.global_position
	var atan_ = atan2(diff_.y, diff_.x) - PI/2
	if length0_+length1_ < length2_:
		joint_2.global_rotation = atan_
		joint_21.global_rotation = atan_
	else:
		var cosAngle0 = ((length2_ * length2_) + (length0_ * length0_) - (length1_ * length1_)) / (2 * length2_ * length0_)
		var angle0 = acos(cosAngle0)
		# Inner angle beta
		var cosAngle1 = ((length1_ * length1_) + (length0_ * length0_) - (length2_ * length2_)) / (2 * length1_ * length0_)
		var angle1 = acos(cosAngle1)

		joint_2.rotation = atan_+angle0
		joint_21.rotation = PI + angle1
		
	if state != ACTIVE:
		autobalance(delta)
		return
	
	# MOVEMENT 
	var horz1 = Input.get_action_strength("right") - Input.get_action_strength("left")
	if keys:
		mouse_vel.x = horz1 * 20
	if abs(body.rotation) < max_lean and wheel.is_on_floor:
		wheel.apply_torque_impulse(-wheelt_pid.step(wheel.angular_velocity - wheel_vel_to_lean_ratio * fmod(body.rotation, 2 * PI)/max_lean, delta) * delta)
	if wheel.is_on_floor:
		body.apply_impulse(Vector2(mouse_vel.x * ground_lean * Global.sense, 0), Vector2(0, -250))
	else:
		body.apply_central_impulse(Vector2(mouse_vel.x * air_movement * Global.sense, 0))
		body.apply_impulse(Vector2(mouse_vel.x * air_lean * Global.sense, 0), Vector2(0, -250))
	
	# JUMPING
	if Input.is_action_just_released("jump"):
		if jump_mult > 0 and jump_cooldown <= 0.0 and wheel.is_on_floor:
			jump_cooldown = jump_cooldown_max
			body.apply_central_impulse(Vector2.UP.rotated(fmod(body.rotation, 2 * PI)) * init_jump_speed * (jump_mult*3/4 + 0.25)) 
			# extra numbers to start it at .25 and go to 1
		jump_mult = 0
	if jump_cooldown > 0.0:
		jump_cooldown -= delta
	if Input.is_action_pressed("jump"):
		jump_mult += delta * 1 / jump_charge_time
		jump_mult = clamp(jump_mult, 0, 1.0)

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
