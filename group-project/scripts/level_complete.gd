extends CanvasLayer

@onready var return_start_button := $CenterContainer/VBoxContainer/ReturnStartButton


func _on_return_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/StartScene.tscn")
