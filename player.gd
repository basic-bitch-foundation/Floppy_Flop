extends CharacterBody2D

const SPEED = 100
const JUMP_FORCE = -300
const GRAVITY = 600

var score = 0
@onready var tilemap = get_parent().get_node("TileMap/Layer0") 
func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0

	# Horizontal movement
	velocity.x = 0
	if Input.is_action_pressed("move_right"):
		velocity.x += SPEED
	if Input.is_action_pressed("move_left"):
		velocity.x -= SPEED

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE

	# Apply movement
	move_and_slide()

	# Check for collectibles under/around player
	_check_collectibles()

func _check_collectibles() -> void:
	if tilemap == null:
		return

	# Player collision box in tilemap coordinates
	var half_size = Vector2(8, 8) # adjust to your tile/player size
	var min_tile = tilemap.local_to_map(global_position - half_size)
	var max_tile = tilemap.local_to_map(global_position + half_size)

	# Loop through all overlapped tiles
	for tx in range(int(min_tile.x), int(max_tile.x) + 1):
		for ty in range(int(min_tile.y), int(max_tile.y) + 1):
			var coords = Vector2i(tx, ty)
			var tile_data = tilemap.get_cell_tile_data(coords)
			if tile_data and tile_data.has_custom_data("type"):
				var t = tile_data.get_custom_data("type")
				if t == "collectible":
					score += 1
					tilemap.erase_cell(coords)
					print("Collected! Score: ", score)
