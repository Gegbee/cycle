extends RigidBody2D

var is_on_floor = false

func _integrate_forces(state):
	var temp_is_on_floor = false
	for contact in state.get_contact_count():
		var normal = state.get_contact_local_normal(contact)
		if abs(normal.x) < 0.3 and normal.y < 0.7:
			temp_is_on_floor = true
	is_on_floor = temp_is_on_floor
	


func _on_body_entered(body):
	pass
	#apply_central_impulse(Vector2.UP * linear_velocity.y / 2 * 1000000)
