extends StaticBody2D


var init_pos : Vector2 = Vector2()
var falling : = false
var time : float = 0.0
func _ready():
	add_to_group('falling')
	init_pos = $F1.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if falling:
		time += delta
		$F1.position.y += time * time * 8.0


func start_fall():
	if $Timer.time_left == 0:
		$Timer.start(1.5)
		

func _on_timer_timeout():
	if !falling:
		time = 0.0
		$CollisionPolygon2D.disabled = true
		falling = true
		$Timer.start(5.0)
		$GPUParticles2D.emitting = false
	else:
		falling = false
		$CollisionPolygon2D.disabled = false
		$F1.position.y = init_pos.y
		$GPUParticles2D.emitting = true
