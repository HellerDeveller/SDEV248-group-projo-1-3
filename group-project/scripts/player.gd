extends CharacterBody2D
class_name Player

@export var projectile_scene: PackedScene
@export var move_speed: float = 80.0
@export var max_health: int = 3

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_health: int = max_health
var facing := Vector2.DOWN # default facing dir
var is_attacking := false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		shoot_projectile()

func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO
	
	# use elif to ensure only one dir active; prevents diagonal movement
	# right movement - 
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	# left movement
	elif Input.is_action_pressed("ui_left"):
		direction.x -= 1
	# down movement
	elif Input.is_action_pressed("ui_down"):
		direction.y += 1
	# up movement
	elif Input.is_action_pressed("ui_up"):
		direction.y -= 1

	direction = direction.normalized()
	velocity = direction * move_speed
	move_and_slide()
	
	if direction != Vector2.ZERO:
		facing = direction
		
	if not is_attacking:
		update_facing(direction)
	
# fill out func later for advanced direction flipping etc
func update_facing(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		# idle anim
		if facing.y > 0:
			sprite.play("idle_down")
			sprite.flip_h = false
		elif facing.y < 0:
			sprite.play("idle_up")
			sprite.flip_h = false
		else:
			sprite.play("idle_side")
			sprite.flip_h = facing.x < 0
	else:
		# walk
		if direction.y > 0:
			sprite.play("walk_down")
			sprite.flip_h = false
		elif direction.y < 0:
			sprite.play("walk_up")
			sprite.flip_h = false
		else:
			sprite.play("walk_side")
			sprite.flip_h = direction.x < 0
	
	
func take_damage(amount: int = 1) -> void:
	current_health -= amount
	print("player took damage. current health: ", current_health)
	
	var hud = get_tree().root.get_node("MainScene/Hud")
	hud.set_health(current_health)
	
	if current_health <= 0:
		print("player out of lives")
		trigger_game_over()
		


func trigger_game_over():
	get_tree().paused = true
	var game_over_screen = preload("res://scenes/GameOver.tscn").instantiate()
	get_tree().current_scene.add_child(game_over_screen)
	game_over_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	
	
	
func shoot_projectile():
	
	var projectile = projectile_scene.instantiate() # create an instance of projectile
	
	# spawn slightly in front of player 
	var spawn_offset := Vector2.ZERO
	var spawn_distance := 12
	
	# logic for spawn offset
	if facing.y > 0:
		spawn_offset = Vector2(0, spawn_distance) # down
	elif facing.y < 0:
		spawn_offset = Vector2(0, -spawn_distance) # up
	elif facing.x > 0:
		spawn_offset = Vector2(spawn_distance, 0) # right
	elif facing.x < 0:
		spawn_offset = Vector2(-spawn_distance, 0) # left
		
	projectile.global_position = global_position + spawn_offset
	projectile.direction = facing
	get_tree().current_scene.add_child(projectile)
	
	is_attacking = true
	
	# attack anim
	if facing.y > 0:
		sprite.play("attack_down")
		sprite.flip_h = false
	elif facing.y < 0:
		sprite.play("attack_up")
		sprite.flip_h = false
	else: 
		sprite.play("attack_side")
		sprite.flip_h = facing.x < 0


func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false
		update_facing(Vector2.ZERO)
