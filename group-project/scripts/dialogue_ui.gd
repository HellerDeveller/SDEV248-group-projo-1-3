extends Control

signal dialogue_finished
signal choice_made(answer: bool)

@onready var label = $Panel/Label
@onready var continue_label = $Panel/ContinueIndicator
@onready var portrait_sprite = $Panel/Panel/PotraitSprite
@onready var choice_box = $ChoiceBox
@onready var yes_button = $ChoiceBox/YesButton
@onready var no_button = $ChoiceBox/NoButton

var lines: Array[String] = []
var current_line_index = 0
var is_showing = false
var char_index := 0
var typing_speed := 0.03
var typing_timer := 0.0
var continue_timer := 0.0
var continue_delay := 0.5



func _ready():
	hide()
	continue_label.visible = false
	
	choice_box.visible = false
	

func _process(delta: float) -> void:
	if is_showing:
		var full_line = lines[current_line_index - 1]
		
		if char_index < full_line.length():
			typing_timer -= delta
			if typing_timer <= 0:
				char_index += 1
				label.text = full_line.substr(0, char_index)
				typing_timer = typing_speed
			continue_label.visible = false
			continue_timer = 0.0
		else:
			continue_timer += delta
			if continue_timer >= continue_delay:
				continue_label.visible = true

func start_dialogue(new_lines: Array[String]):
	print("starting new dialogue")
	lines = new_lines
	current_line_index = 0
	is_showing = true
	continue_timer = 0.0
	char_index = 0
	label.text = ""
	
	choice_box.visible = false
	show()
	portrait_sprite.play("default")
	show_next_line()
	
func show_next_line():
	continue_label.visible = false
	continue_timer = 0.0
	
	if current_line_index < lines.size():
		# typewriter
		char_index = 0
		typing_timer = typing_speed
		label.text = ""
		current_line_index += 1
	else:
		end_dialogue()
		
func end_dialogue():
	is_showing = false
	print("dialogue ended, hiding")
	hide()
	label.text = ""
	continue_label.visible = false
	emit_signal("dialogue_finished")
	
func show_choice():
	print("showing choice button")
	is_showing = false
	continue_label.visible = false
	label.text = ""
	choice_box.visible = true
	

func _unhandled_input(event: InputEvent) -> void:
	if is_showing and event.is_action_pressed("interact"):
		var full_line := lines[current_line_index - 1]
		
		if label.text.length() < full_line.length():
			label.text = full_line
			char_index = full_line.length()
		else:
			show_next_line()
			
		
func _on_yes_button_pressed() -> void:
	choice_box.visible = false
	emit_signal("choice_made", true)


func _on_no_button_pressed() -> void:
	choice_box.visible = false
	emit_signal("choice_made", false)
