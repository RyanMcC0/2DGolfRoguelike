extends Node2D

var branch_counts  = [1,2,3,4,5,4,3,2,1]
const START_POS    = Vector2(200, 450)
const X_SPACING    = 200
const SCREEN_HEIGHT = 900
const HOLE_SCENE   = "res://Scenes/Level_Hole.tscn"

func _ready():
	# Load your hole scene once
	var hole_packed = load(HOLE_SCENE)

	for col_idx in branch_counts.size():
		var count = branch_counts[col_idx]
		var x = START_POS.x + col_idx * X_SPACING

		for hole_idx in count:
			var y = (hole_idx + 1) * (SCREEN_HEIGHT / (count + 1))
			var hole = hole_packed.instantiate()
			add_child(hole)
			hole.position = Vector2(x, y)

			var hover_area = hole.get_node("Hover_Area") as Area2D
			if hover_area:
				var cb = Callable(self, "_on_hole_input").bind(col_idx,hole_idx)
				hover_area.connect("input_event", cb)
			else:
				push_error("Miising HoverArea on LevelHole Instance")

# Placeholder: prints which hole was clicked
func _on_hole_input(viewport, event, shape_idx, col_idx, hole_idx):
	if event is InputEventMouseButton and event.pressed:
		print("Column %d, Hole %d clicked!" % [col_idx, hole_idx])
