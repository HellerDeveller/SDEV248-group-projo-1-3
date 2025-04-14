extends Area2D

@export var target_room: Vector2
@export var own_room: Vector2

@onready var target_pos: Vector2 = $TargetMarker.global_position
@onready var hud = get_tree().root.get_node("MainScene/Hud")
@onready var main_scene = get_tree().root.get_node("MainScene")
@onready var blocker = $StaticBody2D/CollisionShape2D

func _ready():
	add_to_group("warps")
	call_deferred("check_activation")
	print("Blocker valid? ", blocker != null)

func _on_body_entered(body):
	if body is Player and blocker.disabled:
		print(" Warp triggered from ", main_scene.get_current_room(), " to ", target_room)
		body.global_position = target_pos
		main_scene.update_enemies_in_room(target_room)
		
func check_activation():
	var current_room = main_scene.get_current_room()
	var defeated = hud.enemies_defeated_by_room.get(own_room, 0)
	var total = hud.total_enemies_by_room.get(own_room, 0)

	
	if defeated >= total and total > 0:
		print("Warp OPEN for room ", own_room)
		blocker.set_deferred("disabled", true)
	else:
		print(" Warp BLOCKED for room ", own_room)
		blocker.set_deferred("disabled", false)
