extends Node2D


const SCREEN_SIZE = Vector2(640, 384)

@onready var player = $Player
@onready var hud = $Hud

var previous_room: Vector2 = Vector2(-1, -1)

func _ready():
	var final_door = get_node("FinalDoor")
	final_door.final_door_entered.connect(_on_final_door_entered)
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var room = enemy.room_coord
		var count = 0
		for e in get_tree().get_nodes_in_group("enemies"):
			if e.room_coord == room:
				count += 1
		hud.set_total_enemies(room, count)
	
	var start_room = Vector2(
		floor(player.global_position.x / SCREEN_SIZE.x),
		floor(player.global_position.y / SCREEN_SIZE.y)
	)
	update_enemies_in_room(start_room)
	previous_room = start_room
	
func _process(_delta):
	var current_room = Vector2(
		floor(player.global_position.x / SCREEN_SIZE.x),
		floor(player.global_position.y / SCREEN_SIZE.y)
	)
	
	if current_room != previous_room:
		update_enemies_in_room(current_room)
		previous_room = current_room
	

func update_enemies_in_room(current_room: Vector2):
	
	var count = 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		print(" Room coord from enemy: ", enemy.room_coord, " | Current room: ", current_room)
		if enemy.room_coord == current_room:
			count += 1
		
	hud.set_current_room(current_room)
	hud.set_total_enemies(current_room, count)
	
	var warps = get_tree().get_nodes_in_group("warps")
	print("warps in group: ", warps)
	for warp in warps:
		print("warp in loop:  ", warp.name)
		warp.check_activation()


func get_current_room() -> Vector2:
	return previous_room
	

func check_level_completion():
	var total := 0
	var defeated := 0
	
	for room in hud.total_enemies_by_room:
		var room_total = hud.total_enemies_by_room[room]
		var room_defeated = hud.enemies_defeated_by_room.get(room, 0)
		print("ROOM ", room, ": ", room_defeated, "/", room_total)
		total += room_total
		defeated += room_defeated
		
	print(">> LEVEL STATUS: defeated = %d / total = %d" % [defeated, total])
	
	if defeated >= total and total > 0:
		var final_door = get_node("FinalDoor")
		final_door.unlock()

func _on_final_door_entered():
	print("final cutscene triggered")
	
	
