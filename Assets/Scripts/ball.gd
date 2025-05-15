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
	mat.friction = 0.4
	mat.bounce = 0.4
	physics_material_override = mat
	input_pickable = true

# Tuning parameters
var max_power = 1000 # max launch force
var power_multiplier = 5 # tweak this to make dragging feel right
var velocity_clamp = 8 # this is a linear_velocity.length_squared() limit.

func _physics_process(delta: float) -> void:
	if (linear_velocity.length_squared() < velocity_clamp):
		linear_velocity = Vector2.ZERO
		launched = false

# Handles input on actual node... CollisionShape2D here.
func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if (linear_velocity.length_squared() > velocity_clamp): # Prevent dragging if the ball is moving
		return
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		is_dragging = true
		drag_start = self.global_position
		drag_end = drag_start
	if (drag_end and not is_dragging):
		launched = true

func _input(event):
	# Spin mechanic
	if (launched and not is_dragging and event is InputEventKey and event.pressed):
		if Input.is_action_pressed("rotate_left"):
			apply_torque_impulse(-1000)
		if Input.is_action_pressed("rotate_right"):
			apply_torque_impulse(1000)
			
	# Prevent dragging or launching if the ball is moving
	if (linear_velocity.length_squared() > velocity_clamp):
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
	launched = true
	var drag_vector = drag_start - drag_end
	var power = drag_vector.length() * power_multiplier
	power = clamp(power, 0, max_power)

	var direction = drag_vector.normalized()
	apply_central_impulse(direction * power)
	drag_end = Vector2.ZERO
	drag_start = Vector2.ZERO


func _draw():
	if is_dragging:
		var drag_vector = drag_start - drag_end
		var power = drag_vector.length() * power_multiplier
		power = clamp(power, 0, max_power)
		var direction = drag_vector.normalized()

		# Convert force to initial velocity
		var initial_velocity = (power / self.mass) * direction

		# Calculate the trajectory points
		var points = []
		var gravity = ProjectSettings.get("physics/2d/default_gravity")
		var time_step = 0.05
		var max_time = 2.0 # Adjust this to control the length of the arc
		var start_color = Color(0, 1, 0) # Green
		var end_color = Color(1, 0, 0)   # Red


		for t in range(0, int(max_time / time_step)):
			var time = t * time_step
			var position = initial_velocity * time + 0.5 * Vector2(0, gravity) * time * time
			points.append(to_local(drag_start + position))

		for i in range(points.size() - 1):
			var t = float(i) / (points.size() - 1)
			var color = Color(
				lerp(start_color.r, end_color.r, t),
				lerp(start_color.g, end_color.g, t),
				lerp(start_color.b, end_color.b, t),
				lerp(start_color.a, end_color.a, t)
			)
			color.a = 1.0 - t # Fade out
			draw_dashed_line(points[i], points[i + 1], color, 4, 10)
