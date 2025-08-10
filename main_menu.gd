extends Control

@export var main_game_scene: PackedScene

@export var icon_sound_on: Texture
@export var icon_sound_off: Texture

@onready var play_button: TextureButton = $PlayButton
@onready var sound_button: TextureButton = $SoundButton
@onready var start_sfx: AudioStreamPlayer = $StartSFX
@onready var click_sfx: AudioStreamPlayer = $ClickSFX

@onready var how_to_play_panel: Panel = $HowToPlayPanel
@onready var how_to_play_button: TextureButton = $HowToPlayButton
@onready var how_to_play_close_button: TextureButton = $HowToPlayPanel/CloseButton

func _ready():
	play_button.pressed.connect(_on_play_button_pressed)
	sound_button.pressed.connect(_on_sound_button_pressed)
	how_to_play_button.pressed.connect(_on_how_to_play_button_pressed)
	how_to_play_close_button.pressed.connect(_on_close_button_pressed)

	how_to_play_panel.visible = false

	
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not Global.sound_on)
	_update_sound_button_icon()

func _on_play_button_pressed():
	if Global.sound_on and start_sfx:
		start_sfx.play()
	await get_tree().create_timer(0.25).timeout
	
	if main_game_scene:
		get_tree().change_scene_to_packed(main_game_scene)

func _on_sound_button_pressed():
	if Global.sound_on and click_sfx:
		click_sfx.play()

	Global.sound_on = !Global.sound_on
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not Global.sound_on)
	_update_sound_button_icon()

func _update_sound_button_icon():
	if Global.sound_on:
		sound_button.texture_normal = icon_sound_on
	else:
		sound_button.texture_normal = icon_sound_off

func _on_how_to_play_button_pressed():
	how_to_play_panel.visible = true

func _on_close_button_pressed():
	how_to_play_panel.visible = false
