extends CanvasLayer

@onready var try_again_button := $CenterContainer/VBoxContainer/TryAgainButton



func _on_try_again_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")
