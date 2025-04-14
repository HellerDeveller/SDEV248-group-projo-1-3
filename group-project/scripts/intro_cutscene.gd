extends Control

@export var text_to_display := """
The year is XXXXX, the hierarchy has shifted. 
The new emerging wildlife have proved themselves a force beyond nature and inhabited the environment that was once yours. 
What was once ruled by humans is now under possession of monsters. Many tried to rebel against the inevitable as well as meet the short end of the stick. 
With a near extinction crisis, the monsters gracefully crushed the ‘Human’ title and life would continue under their control…

Anyway, you play as Sic, a weary stoic who accidentally wandered into their territory (while chasing some dust), and you gotta find your way out!
"""
@export var char_delay := 0.03
@export var tutorial_scene := preload("res://scenes/TutorialRoom.tscn")

@onready var label := $Label
@onready var begin_button := $BeginButton

var current_index := 0
var time_passed := 0.0
var finished_typing := false

func _ready():
	begin_button.visible = false
	begin_button.disabled = true
	label.text = ""

func _process(delta):
	if not finished_typing and current_index < text_to_display.length():
		time_passed += delta
		if time_passed >= char_delay:
			time_passed = 0.0
			current_index += 1
			label.text = text_to_display.substr(0, current_index)
	elif not finished_typing:
		finished_typing = true
		begin_button.visible = true
		begin_button.disabled = false


func _on_begin_button_pressed() -> void:
	start_tutorial()
	
func start_tutorial():
	get_tree().change_scene_to_packed(tutorial_scene)
