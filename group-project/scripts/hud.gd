extends CanvasLayer

@onready var hearts := [
	$HeartContainer/Heart1,
	$HeartContainer/Heart2,
	$HeartContainer/Heart3
]

@onready var enemy_label: Label = $EnemyTracker

var max_health := 3
var current_health := 3
var total_enemies_by_room := {}
var enemies_defeated_by_room := {}
var current_room := Vector2.ZERO

func _ready():
	update_hearts()
	update_enemy_tracker()

func set_health(value: int):
	current_health = clamp(value, 0, max_health)
	update_hearts()

func update_hearts():
	for i in range(hearts.size()):
		hearts[i].visible = i < current_health
		
func set_total_enemies(room: Vector2, value: int):
	if not total_enemies_by_room.has(room):
		total_enemies_by_room[room] = value
		enemies_defeated_by_room[room] = 0
		
	current_room = room
	update_enemy_tracker()
	
func increment_enemy_kill():
	if not enemies_defeated_by_room.has(current_room):
		enemies_defeated_by_room[current_room] = 0
	enemies_defeated_by_room[current_room] += 1
	update_enemy_tracker()
	
func update_enemy_tracker():
	var defeated = enemies_defeated_by_room.get(current_room, 0)
	var total = total_enemies_by_room.get(current_room, 0)
	
	if defeated >= total and total > 0:
		enemy_label.text = "Room Cleared!"
	else:
		enemy_label.text = str(defeated) + " / " + str(total)
	
func set_current_room(room: Vector2):
	current_room = room
	update_enemy_tracker()
