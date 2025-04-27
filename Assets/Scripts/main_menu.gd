extends Control

#grab audioplayers
@onready var hover_sfx = $SfxHover
@onready var click_sfx = $SfxClick

func _on_btn_start_pressed() -> void:
	$CenterContainer/Vbox/BtnStart.scale = Vector2(1, 1)
	click_sfx.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://Scenes/baseGame.tscn")


func _on_btn_options_pressed() -> void:
	pass # Replace with function body.


func _on_btn_exit_pressed() -> void:
	$CenterContainer/Vbox/BtnStart.scale = Vector2(1, 1)
	click_sfx.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()

#Start button on hover effects
func _on_btn_start_mouse_entered() -> void:
	$CenterContainer/Vbox/BtnStart.modulate = Color(1.2, 1.2, 1.2)
	hover_sfx.play()


func _on_btn_start_mouse_exited() -> void:
	$CenterContainer/Vbox/BtnStart.modulate = Color(1, 1, 1)

#Options button on hover effects
func _on_btn_options_mouse_entered() -> void:
	$CenterContainer/Vbox/BtnOptions.modulate = Color(1.2, 1.2, 1.2)
	hover_sfx.play()


func _on_btn_options_mouse_exited() -> void:
	$CenterContainer/Vbox/BtnOptions.modulate = Color(1, 1, 1)

#Exit button on hover effects
func _on_btn_exit_mouse_entered() -> void:
	$CenterContainer/Vbox/BtnExit.modulate = Color(1.2, 1.2, 1.2)
	hover_sfx.play()


func _on_btn_exit_mouse_exited() -> void:
	$CenterContainer/Vbox/BtnExit.modulate = Color(1, 1, 1)
