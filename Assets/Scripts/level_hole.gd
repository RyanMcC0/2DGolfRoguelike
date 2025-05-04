extends Node2D

const HOVER_OFFSET_Y := -4
const HOVER_TIME     := 0.25

@onready var flag := $SpriteFlag

func _ready():
	#hide flag at start, Ensure flush
	flag.hide()
	flag.position.y = 0

func _on_hover_area_mouse_entered() -> void:
	flag.show()
	var t = create_tween()
	t.tween_property(flag, "position:y",HOVER_OFFSET_Y, HOVER_TIME)


func _on_hover_area_mouse_exited() -> void:
	var t = create_tween()
	t.tween_property(flag, "position:y",0, HOVER_TIME)
	t.tween_callback( Callable(flag, "hide") )
