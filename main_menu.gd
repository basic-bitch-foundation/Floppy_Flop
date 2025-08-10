extends Control

@export var main_game_scene: PackedScene

@onready var play_button: TextureButton = $PlayButton
@onready var sound_button: TextureButton = $SoundButton
@onready var start_sfx: AudioStreamPlayer2D = $StartSFX
@onready var click_sfx: AudioStreamPlayer2D = $ClickSFX

var sound_on := true

func _ready():
	# Internal signal connections
	play_button.pressed.connect(_on_play_button_pressed)
	sound_button.pressed.connect(_on_sound_button_pressed)

func _on_play_button_pressed():
	if sound_on and start_sfx:
		start_sfx.play()
	# Wait a short moment so sound isn't cut off
	await get_tree().create_timer(0.25).timeout
	# Switch to game scene
	if main_game_scene:
		get_tree().change_scene_to_packed(main_game_scene)

func _on_sound_button_pressed():
	if sound_on and click_sfx:
		click_sfx.play()
	sound_on = !sound_on
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not sound_on)
