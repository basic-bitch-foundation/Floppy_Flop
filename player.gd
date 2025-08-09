extends CharacterBody2D

const SPEED = 100
const JUMP_FORCE = -300
const GRAVITY = 600

var score: int = 0

var on_bad_tile_area: bool = false
var bad_tile_area_timer: float = 0.0
const BAD_TILE_DAMAGE_INTERVAL := 1.0 

@onready var tilemap_layer0: TileMapLayer = get_tree().get_current_scene().get_node("TileMap/Layer0")
@onready var bad_tile_detector = $BadTileDetector

func _ready() -> void:
	bad_tile_detector.connect("body_entered", Callable(self, "_on_bad_tile_entered"))
	bad_tile_detector.connect("body_exited", Callable(self, "_on_bad_tile_exited"))

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0

	velocity.x = 0
	if Input.is_action_pressed("move_right"):
		velocity.x += SPEED
	if Input.is_action_pressed("move_left"):
		velocity.x -= SPEED

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE

	move_and_slide()

	
	_check_collectibles(delta)

	
	if on_bad_tile_area:
		bad_tile_area_timer += delta
		if bad_tile_area_timer >= BAD_TILE_DAMAGE_INTERVAL:
			score -= 1
			bad_tile_area_timer = 0.0
			print("Ouch! On bad tile area! Score:", score)
	else:
		bad_tile_area_timer = 0.0

func _check_collectibles(_delta: float) -> void:
	if tilemap_layer0 == null:
		return

	var detect_points = [
		Vector2(-4, 6),
		Vector2(0, 6),
		Vector2(4, 6),
	]

	for offset in detect_points:
		var detect_pos = tilemap_layer0.to_local(global_position + offset)
		var tile_coords: Vector2i = tilemap_layer0.local_to_map(detect_pos)
		var tile_data: TileData = tilemap_layer0.get_cell_tile_data(tile_coords)

		if tile_data and tile_data.has_custom_data("type"):
			var t = tile_data.get_custom_data("type")

			if t == "collectible":
				score += 1
				tilemap_layer0.set_cell(tile_coords, -1)
				print("Collected! Score:", score)

func _on_bad_tile_entered(_body: Node) -> void:
	on_bad_tile_area = true
	print("Entered bad tile area")

func _on_bad_tile_exited(_body: Node) -> void:
	on_bad_tile_area = false
	print("Exited bad tile area")
