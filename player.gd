extends CharacterBody2D

const SPEED = 100
const JUMP_FORCE = -300
const GRAVITY = 600

var score: float = 0.0

const BIT_TO_KB = 0.1
const DAMAGE_PER_SECOND = 10 * BIT_TO_KB

var on_bad_tile_area: bool = false
var game_started: bool = false
var restart_timer: Timer
var restart_cooldown: float = 1.5 
var time_since_start: float = 0.0
var restart_pending: bool = false

@onready var tilemap_layer0: TileMapLayer = get_tree().get_current_scene().get_node("TileMap/Layer0")
@onready var bad_tile_detector = $BadTileDetector
@onready var score_label = get_tree().get_current_scene().get_node("CanvasLayer/ScoreLabel")
@onready var camera: Camera2D = get_node("/root/Game/Camera2D")

# 🎵 Audio nodes (all should be child nodes of Player)
@onready var sfx_jump: AudioStreamPlayer = $SFX_Jump
@onready var sfx_damage: AudioStreamPlayer = $SFX_Damage
@onready var sfx_collect: AudioStreamPlayer = $SFX_Collect
@onready var sfx_lose: AudioStreamPlayer = $SFX_Lose
@onready var sfx_restart: AudioStreamPlayer = $SFX_Restart
@onready var bgm: AudioStreamPlayer = $BGM

# Win condition vars
@export var win_sprite_path: NodePath
@onready var win_sprite: Sprite2D = null

@export var main_menu_scene: PackedScene

const DEATH_TOP_MARGIN = 20.0  # margin so player doesn’t die immediately on top edge

func _ready() -> void:
	bad_tile_detector.connect("body_entered", Callable(self, "_on_bad_tile_entered"))
	bad_tile_detector.connect("body_exited", Callable(self, "_on_bad_tile_exited"))
	_update_score_label()

	time_since_start = 0.0
	game_started = false
	restart_pending = false

	restart_timer = Timer.new()
	restart_timer.wait_time = 1.0
	restart_timer.one_shot = true
	restart_timer.connect("timeout", Callable(self, "_on_restart_timer_timeout"))
	add_child(restart_timer)

	if bgm:
		bgm.stop() 

	if sfx_restart:
		sfx_restart.play() 

	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not Global.sound_on)

	if win_sprite_path != null:
		win_sprite = get_node(win_sprite_path)
	else:
		print("Warning: Win sprite path not assigned!")

func _physics_process(delta: float) -> void:
	
	if (Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left") or score > 0) and not game_started:
		game_started = true
		if bgm and not bgm.playing:
			bgm.play()

	if game_started:
		time_since_start += delta

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
		if sfx_jump:
			sfx_jump.play()

	move_and_slide()

	_check_collectibles(delta)

	if on_bad_tile_area:
		var damage = DAMAGE_PER_SECOND * delta
		score = max(score - damage, 0)
		_update_score_label()
		if sfx_damage and not sfx_damage.playing:
			sfx_damage.play()
		
		if score == 0:
			if sfx_lose:
				sfx_lose.play()
			_start_restart_timer()
	else:
		if sfx_damage and sfx_damage.playing:
			sfx_damage.stop()

	_check_lose_conditions()

	# Win condition check
	if win_sprite != null:
		var distance_to_win = global_position.distance_to(win_sprite.global_position)
		if distance_to_win < 32.0:
			if score > 0:
				_win_game()
			else:
				print("No data collected, restarting...")
				get_tree().reload_current_scene()

func _check_lose_conditions() -> void:
	if camera == null:
		return
	if not game_started or time_since_start < restart_cooldown:
		return

	var viewport_size = get_viewport().get_visible_rect().size
	var zoom = camera.zoom
	var half_size = (viewport_size * zoom) * 0.299
	var top_left = camera.global_position - half_size
	var visible_rect = Rect2(top_left, half_size * 2)

	if global_position.y < visible_rect.position.y - DEATH_TOP_MARGIN:
		if sfx_lose:
			sfx_lose.play()
		_start_restart_timer()

func _start_restart_timer() -> void:
	if restart_pending or restart_timer.is_stopped() == false:
		return
	restart_pending = true
	restart_timer.start()

func _on_restart_timer_timeout() -> void:
	restart_pending = false
	get_tree().reload_current_scene()

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
				if sfx_collect:
					sfx_collect.play()

func _on_bad_tile_entered(_body: Node) -> void:
	on_bad_tile_area = true

func _on_bad_tile_exited(_body: Node) -> void:
	on_bad_tile_area = false

func _update_score_label() -> void:
	score_label.text = "%0.2f KB" % score

func _win_game():
	print("You win! Returning to Main Menu...")
	if main_menu_scene != null:
		get_tree().change_scene_to_packed(main_menu_scene)
	else:
		print("Main menu scene not assigned! Restarting current scene.")
		get_tree().reload_current_scene()
