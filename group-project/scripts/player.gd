extends CharacterBody2D
class_name Player

@export var move_speed: float = 60.0
@export var max_health: int = 3

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_health: int = max_health

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
		
	if direction.x != 0:
		$AnimatedSprite2D.flip_h = direction.x < 0
		
	direction = direction.normalized()
	velocity = direction * move_speed
	move_and_slide()

# fill out func later for advanced direction flipping etc
func update_facing(direction: Vector2) -> void:
	pass
	
	
func take_damage(amount: int = 1) -> void:
	current_health -= amount
	print("player took damage. current health: ", current_health)
	
	if current_health <= 0:
		print("player out of lives")
		# handle game over later?
