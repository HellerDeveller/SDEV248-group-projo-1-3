extends CharacterBody2D

@export var move_speed := 20.0
@export var door_path: NodePath

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var patrol_points: Array[Vector2] = []
@onready var dialogue_ui = get_parent().get_node("DialogueUi")
@onready var interact_label = $InteractLabel

var player_in_area := false
var current_patrol_index := 0
var is_patrolling := true
var player: Node2D = null
var door: Area2D
var dialogue_completed = false
var dialogue_just_finished := false
var dialogue_cooldown := 0.5 # half a second
var dialogue_timer := 0.0
var awaiting_reminder_choice := false


func _ready():
	dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)
	
	for point in $PatrolPoints.get_children():
		if point is Marker2D:
			patrol_points.append(point.global_position)
			
	if door_path != NodePath():
		door = get_node(door_path)

func _physics_process(delta: float) -> void:
	if dialogue_just_finished:
		dialogue_timer -= delta
		if dialogue_timer <= 0:
			dialogue_just_finished = false
			
	if is_patrolling:
		patrol(delta)
	elif player_in_area:
		look_at_player()
		
func patrol(delta):
	if patrol_points.size() < 2:
		return
	
	var target = patrol_points[current_patrol_index]
	var direction = (target - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()
	
	# flip anim based on dir
	if abs(direction.x) > abs(direction.y):
		sprite.play("side")
		sprite.flip_h = direction.x < 0
	elif direction.y < 0:
		sprite.play("up")
	else:
		sprite.play("down")
	
	# check if close
	if global_position.distance_to(target) < 4:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
		

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		player_in_area = true
		is_patrolling = false
		velocity = Vector2.ZERO
		interact_label.visible = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_area = false
		is_patrolling = true
		player = null
		interact_label.visible = false

func look_at_player():
	if not player:
		return
	
	var direction = player.global_position - global_position
	if abs(direction.x) > abs(direction.y):
		sprite.play("side")
		sprite.flip_h = direction.x < 0
	elif direction.y < 0:
		sprite.play("up")
	else:
		sprite.play("down")

func _unhandled_input(event: InputEvent) -> void:
	if player_in_area and event.is_action_pressed("interact") and not dialogue_ui.is_showing:
		if dialogue_just_finished and not awaiting_reminder_choice:
			dialogue_just_finished = false
			return
			
		if dialogue_completed:
			start_reminder_choice()
		else:
			start_dialogue()
		
func start_dialogue():
	print("npc: starting dialogue")
	is_patrolling = false
	
	var lines: Array[String] = [
		"...",
		"hi traveler.",
		"the path ahead is dangerous. defeat the monsters to open the gate.",
		"good luck.",
	]
	
	dialogue_ui.start_dialogue(lines)
	
func start_reminder_choice():
	# clear out any previous connection to avoid duplicate errors
	if dialogue_ui.dialogue_finished.is_connected(_on_reminder_prompt_finished):
		dialogue_ui.dialogue_finished.disconnect(_on_reminder_prompt_finished)

	dialogue_ui.dialogue_finished.connect(_on_reminder_prompt_finished)

	
	var reminder: Array[String] = [
		"back again?", "need a reminder of your quest?"
		]
	
	awaiting_reminder_choice = true
	dialogue_ui.start_dialogue(reminder)
	
func _on_dialogue_finished():	
	if not dialogue_completed:
		door.unlock()
		print("door unlocked")
		dialogue_completed = true
		
	dialogue_just_finished = true
	dialogue_timer = dialogue_cooldown
	
func _on_reminder_prompt_finished():
	print("reminder dialogue finished, showing choice ")
	dialogue_ui.dialogue_finished.disconnect(_on_reminder_prompt_finished)
	dialogue_ui.show_choice()
	
	if not dialogue_ui.choice_made.is_connected(_on_reminder_choice):
		dialogue_ui.choice_made.connect(_on_reminder_choice)

	awaiting_reminder_choice = false
	
func _on_reminder_choice(answer: bool):
	dialogue_ui.choice_made.disconnect(_on_reminder_choice)

	if answer:
		var yes_reminder: Array[String] = [
			"the path ahead is dangerous. defeat the monsters to open the gate.",
			"good luck."
			]
		dialogue_ui.start_dialogue(yes_reminder)
	else:
		var no_reminder: Array[String] = [
			"good luck."
		]
		dialogue_ui.start_dialogue(no_reminder)
	

	
