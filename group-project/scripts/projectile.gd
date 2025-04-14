extends Area2D

@export var speed: float = 150.0
var direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	position += direction.normalized() * speed * delta
	


func _on_area_entered(area: Area2D) -> void:
	if area.name == "Hurtbox":
		var enemy = area.get_parent()
		if enemy is Enemy:
			enemy.take_damage(1)
			queue_free()



func _on_body_entered(body: Node2D) -> void:
	if body.name == "Hurtbox":
		var enemy = body.get_parent()
		if enemy is Enemy:
			enemy.take_damage(1)
		queue_free()
	elif body is StaticBody2D or body is TileMapLayer:
		queue_free()
