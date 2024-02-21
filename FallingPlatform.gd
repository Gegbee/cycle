extends StaticBody2D


var init_pos : Vector2 = Vector2()
var falling : = false
var time : float = 0.0
@export_node_path("Sprite2D") var sprite_path
var sprite
var timer

func _ready():
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	sprite = get_node(sprite_path)
	add_to_group('falling')
	init_pos = sprite.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if falling:
		time += delta
		sprite.position.y += time * time * 8.0


func start_fall():
	if timer.time_left == 0:
		timer.start(2.0)
		

func _on_timer_timeout():
	if !falling:
		time = 0.0
		$CollisionPolygon2D.disabled = true
		falling = true
		timer.start(5.0)
	else:
		falling = false
		$CollisionPolygon2D.disabled = false
		sprite.position.y = init_pos.y
