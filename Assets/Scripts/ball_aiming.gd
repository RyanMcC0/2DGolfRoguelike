extends Node2D

var ball_node : RigidBody2D
var is_dragging = false
var drag_start = Vector2.ZERO
var drag_end = Vector2.ZERO

func _ready():
	ball_node = get_parent()  # assuming Ball is the parent

func _process(delta):
	if is_dragging:
		queue_redraw()

func _draw():
	if is_dragging:
		draw_line(drag_start - global_position, drag_end - global_position, Color.RED, 2)

func start_drag():
	is_dragging = true
	drag_start = get_global_mouse_position()

func update_drag():
	drag_end = get_global_mouse_position()

func end_drag():
	is_dragging = false
