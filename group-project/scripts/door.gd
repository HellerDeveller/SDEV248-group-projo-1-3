extends Area2D

signal final_door_entered

@export var is_locked: bool = true
@export var target_scene: PackedScene
@export var is_final_door := false

@onready var sprite = $AnimatedSprite2D
@onready var blocker_collider = $StaticBody2D/CollisionShape2D

func _ready():
	update_lock_state()
	body_entered.connect(_on_body_entered)
	
func update_lock_state():
	if is_locked:
		sprite.play("locked")
		blocker_collider.set_deferred("disabled", false)
	else:
		sprite.play("unlock")
		await sprite.animation_finished
		await get_tree().create_timer(0.4).timeout  # add slight delay
		sprite.play("open")
		blocker_collider.set_deferred("disabled", true)

func unlock():
	is_locked = false
	update_lock_state()

func _on_body_entered(body: Node2D) -> void:
	print("body entered door: ", body)
	
	if is_locked or not (body is Player):
		return
	
	print("body entered door: ", body)

	if is_final_door:
		emit_signal("final_door_entered")

	if target_scene:
		call_deferred("_change_scene")

		
func _change_scene():
		get_tree().change_scene_to_packed(target_scene)
