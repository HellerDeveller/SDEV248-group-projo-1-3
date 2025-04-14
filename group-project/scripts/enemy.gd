extends CharacterBody2D

class_name Enemy

@export var move_speed: float = 40.0
@export var chase_speed: float = 60.0
@export var chase_timeout: float = 2.0 # how long to keep chasing after exiting detection zone
@export var patrol_wait_time: float = 0.75 # how long to pause at each patrol pt
@export var damage_cooldown: float = 2.0 # seconds between hits
@export var max_health: int = 3
@export var room_coord: Vector2 = Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $PlayerDetection
@onready var hitbox: Area2D = $Hitbox



var current_patrol_index := 0
var is_waiting_at_patrol := false
var patrol_wait_timer: float = 0.0
var chasing_player := false
var player: Node2D = null
var chase_timer: float = 0.0
var can_damage := true
var damage_timer := 0.0
var hurtbox_in_hitbox: Area2D = null
var current_health: int = max_health
var patrol_points: Array[Vector2] = []
var knockback_vector := Vector2.ZERO
var knockback_timer := 0.0
var knockback_duration := 0.15


func _ready():
	
	# load patrol points
	for point in $PatrolPoints.get_children():
		if point is Marker2D:
			patrol_points.append(point.global_position)
			
	detection_area.body_entered.connect(_on_player_entered)
	detection_area.body_exited.connect(_on_player_exited)
	
func _physics_process(delta: float) -> void:
	# handle knockback override
	if knockback_timer > 0:
		velocity = knockback_vector
		knockback_timer -= delta
		move_and_slide()
		return
		
	# damage cooldown timer
	if not can_damage:
		damage_timer -= delta
		if damage_timer <= 0:
			can_damage = true
			
	# check and apply damage
	if hurtbox_in_hitbox and can_damage:
		var hit_player = hurtbox_in_hitbox.get_parent()
		if hit_player is Player:
			print("enemy hit player")
			hit_player.take_damage(1)
			can_damage = false
			damage_timer = damage_cooldown
			
	# count down chase timer
	if chase_timer > 0:
		chase_timer -= delta
	else:
		chasing_player = false
		player = null
		
	# chase logic
	if chasing_player and player:
		var direction = player.global_position - global_position
		if direction.length() > 0.5:
			direction = direction.normalized()
			velocity = direction * chase_speed
		else:
			velocity = Vector2.ZERO

	# patrol logic
	elif patrol_points.size() >= 2:
		# patrol pause
		if is_waiting_at_patrol:
			velocity = Vector2.ZERO
			patrol_wait_timer -= delta
			if patrol_wait_timer <= 0:
				is_waiting_at_patrol = false
		else:
			var target = patrol_points[current_patrol_index]
			var direction = (target - global_position).normalized()
			velocity = direction * move_speed
			
			# check if reached patrol pt
			if global_position.distance_to(target) < 4.0:
				# start waiting
				is_waiting_at_patrol = true
				patrol_wait_timer = patrol_wait_time
				current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
				#else:
					#velocity = Vector2.ZERO
					
	# apply movement
	move_and_slide()
	
	sprite.play("default")

	# dir flip
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
	
	# print("v: ", velocity, "pos: ", global_position) # debug - - keep this commented out or game will crash!! 
	
# when player enters detection area, chase player		
func _on_player_entered(body):
		if body is Player:
			chasing_player = true
			player = body
			chase_timer = chase_timeout # reset timer

# when player leaves detection area, back to patrol
func _on_player_exited(body):
	if body is Player:
		chase_timer = chase_timeout # start countdown


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "Hurtbox":
		hurtbox_in_hitbox = area


func _on_hitbox_area_exited(area: Area2D) -> void:
	if area.name == "Hurtbox" and area == hurtbox_in_hitbox:
		hurtbox_in_hitbox = null
		
		
func take_damage(amount: int = 1, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	current_health -= amount
	print("enemy took damage. current health: ", current_health)
	
	# apply knockback from player
	if knockback_dir != Vector2.ZERO:
		knockback_vector = knockback_dir.normalized() * 150
		knockback_timer = knockback_duration
	
	flash_red()
	
	if current_health <= 0:
		die()
		
		
func die():
	print("enemy has perished")
	
	# get players current room
	var player = get_tree().get_root().get_node("MainScene/Player")
	var screen_size = Vector2(640, 384)
	var current_room = Vector2(
		floor(player.global_position.x / screen_size.x),
		floor(player.global_position.y / screen_size.y)
	)
	
	if current_room == room_coord:
		var hud = get_tree().get_root().get_node("MainScene/Hud")
		hud.increment_enemy_kill()
		
		var main_scene = get_tree().get_root().get_node("MainScene")
		main_scene.update_enemies_in_room(current_room)
		
		main_scene.check_level_completion() # check if entire lvl cleared
		
		for warp in get_tree().get_nodes_in_group("warps"):
			if warp.target_room == room_coord:
				print("unlocking warp for defeated room:  ", room_coord)
				warp.check_activation()
	queue_free()


func flash_red():
	sprite.modulate = Color(1, 0.3, 0.3) # red tint
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1) # back to normal
