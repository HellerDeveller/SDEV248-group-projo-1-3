extends Camera2D

@export var screen_size: Vector2 = Vector2(640,384)
@export var player_path: NodePath

var player: Node2D

func _ready():
	player = get_node(player_path)
	
func _process(_delta):
	if player:
		var screen_coord = Vector2(
		floor(player.global_position.x / screen_size.x),
		floor(player.global_position.y / screen_size.y)
		)
		var target_pos = screen_coord * screen_size + (screen_size / 2)
		global_position = target_pos
