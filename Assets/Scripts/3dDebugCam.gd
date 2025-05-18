extends Camera3D

@export var move_speed: float = 10.0 # Movement speed
@export var look_sensitivity: float = 0.1 # Mouse look sensitivity

var mouse_delta := Vector2.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Lock the mouse to the window

func _process(delta):
	handle_movement(delta)
	handle_mouse_look()

func handle_movement(delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	if Input.is_action_pressed("move_up"):
		direction += transform.basis.y
	if Input.is_action_pressed("move_down"):
		direction -= transform.basis.y

	direction = direction.normalized()
	global_transform.origin += direction * move_speed * delta

func handle_mouse_look():
	var rotation = Vector3.ZERO
	rotation.x -= mouse_delta.y * look_sensitivity
	rotation.y -= mouse_delta.x * look_sensitivity

	rotation.x = clamp(rotation.x, -PI / 2, PI / 2) # Prevent flipping
	rotation_degrees.x = rotation.x
	rotation_degrees.y += rotation.y

	mouse_delta = Vector2.ZERO

func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
	elif event is InputEventKey and Input.is_key_label_pressed(KEY_ESCAPE):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # Unlock the mouse
