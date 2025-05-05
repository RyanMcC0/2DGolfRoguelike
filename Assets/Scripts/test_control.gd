extends Camera2D

@onready var ball = get_node("../Player")

var lerp_speed = 5.0

func _process(delta):
	global_position = global_position.lerp(ball.global_position, lerp_speed * delta)

func _physics_process(delta):
	if Input.is_action_pressed("ui_right"):
		position.x += 5000 * delta
	if Input.is_action_pressed("ui_left"):
		position.x -= 5000 * delta
	if Input.is_action_pressed("ui_down"):
		position.y += 5000 * delta
	if Input.is_action_pressed("ui_up"):
		position.y -= 5000 * delta
	if Input.is_key_pressed(KEY_Q) and ball.linear_velocity == Vector2.ZERO:
		zoom.x += 0.3 * delta
		zoom.y += 0.3 * delta
	if Input.is_key_pressed(KEY_E) and ball.linear_velocity == Vector2.ZERO:
		zoom.x -= 0.3 * delta
		zoom.y -= 0.3 * delta
