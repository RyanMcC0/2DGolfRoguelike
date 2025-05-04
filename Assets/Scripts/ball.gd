extends RigidBody2D

@export var launch_force: float = 200.0
var launched = false
var is_dragging = false
var drag_start = Vector2.ZERO
var drag_end = Vector2.ZERO


func _ready():
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	linear_damp = 0.075
	var mat = PhysicsMaterial.new()
	mat.friction = 0.3
	mat.bounce = 0.4
	physics_material_override = mat
	input_pickable = true

# Tuning parameters
var max_power = 1000  # max launch force
var power_multiplier = 5  # tweak this to make dragging feel right
var velocity_clamp = 4 # this is a linear_velocity.length_squared() limit.

func _physics_process(delta: float) -> void:
	if (linear_velocity.length_squared() < velocity_clamp):
		linear_velocity = Vector2.ZERO 

# Handles input on actual node... CollisionShape2D here.
func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	print("_event")
	print(event)
	if (linear_velocity.length_squared() > velocity_clamp):  # Prevent dragging if the ball is moving
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_dragging = true
		drag_start = self.global_position
		drag_end = drag_start

func _input(event):
	print("_input")
	print(event)
	if (linear_velocity.length_squared() > velocity_clamp):  # Prevent dragging or launching if the ball is moving
		return
	if not is_dragging:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				drag_end = get_global_mouse_position()
				queue_redraw()
			else:
				is_dragging = false
				drag_end = get_global_mouse_position()
				launch_ball()
				queue_redraw()

	elif event is InputEventMouseMotion:
		if is_dragging:
			drag_end = get_global_mouse_position()
			queue_redraw()

func launch_ball():
	var drag_vector = drag_start - drag_end
	var power = drag_vector.length() * power_multiplier
	power = clamp(power, 0, max_power)

	var direction = drag_vector.normalized()
	apply_central_impulse(direction * power)
	

func _draw():
	if is_dragging:
		var drag_vector = drag_end - drag_start
		var mirrored_drag_end = drag_start - drag_vector

		# Convert to local space using the ball's global transform
		var local_drag_start = to_local(drag_start)
		var local_mirrored_drag_end = to_local(mirrored_drag_end)

		# Draw only the mirrored line
		draw_line(local_drag_start, local_mirrored_drag_end, Color.RED, 2)
