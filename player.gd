extends CharacterBody2D

const SPEED = 100
const JUMP_FORCE = -300
const GRAVITY = 600

var score: float = 0.0

const BIT_TO_KB = 0.1
const DAMAGE_PER_SECOND = 10 * BIT_TO_KB

var on_bad_tile_area: bool = false

@onready var tilemap_layer0: TileMapLayer = get_tree().get_current_scene().get_node("TileMap/Layer0")
@onready var bad_tile_detector = $BadTileDetector
@onready var score_label = get_tree().get_current_scene().get_node("CanvasLayer/ScoreLabel")
@onready var camera: Camera2D = get_node("/root/Game/Camera2D")


func _ready() -> void:
	bad_tile_detector.connect("body_entered", Callable(self, "_on_bad_tile_entered"))
	bad_tile_detector.connect("body_exited", Callable(self, "_on_bad_tile_exited"))
	_update_score_label()

func _physics_process(delta: float) -> void:
	# Gravity
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
		var damage = DAMAGE_PER_SECOND * delta
		score = max(score - damage, 0)
		_update_score_label()
		print("On bad tile! Deducted:", damage, "New score:", score)

	_check_player_in_camera()

func _check_player_in_camera() -> void:
	if camera == null:
		return

	var viewport_size = get_viewport().get_visible_rect().size
	var zoom = camera.zoom
	var half_size = (viewport_size * zoom) * 0.299
	var top_left = camera.global_position - half_size
	var visible_rect = Rect2(top_left, half_size * 2)

	if global_position.y < visible_rect.position.y:
		if score != 0:
			score = 0
			_update_score_label()
			print("Player went above camera view! Score reset to 0")

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
				score += 5 * BIT_TO_KB
				tilemap_layer0.set_cell(tile_coords, -1)
				_update_score_label()
				print("Collected! Score:", score)

func _on_bad_tile_entered(_body: Node) -> void:
	on_bad_tile_area = true
	print("Entered bad tile area")

func _on_bad_tile_exited(_body: Node) -> void:
	on_bad_tile_area = false
	print("Exited bad tile area")

func _update_score_label() -> void:
	score_label.text = "%0.2f KB" % score
