extends Camera2D

func _physics_process(delta):
	if Input.is_action_pressed("ui_right"):
		position.x += 5000 * delta
	if Input.is_action_pressed("ui_left"):
		position.x -= 5000 * delta
	if Input.is_action_pressed("ui_down"):
		position.y += 5000 * delta
	if Input.is_action_pressed("ui_up"):
		position.y -= 5000 * delta
	if Input.is_key_pressed(KEY_Q):
		zoom.x += 0.3 * delta
		zoom.y += 0.3 * delta
	if Input.is_key_pressed(KEY_E):
		zoom.x -= 0.3 * delta
		zoom.y -= 0.3 * delta
