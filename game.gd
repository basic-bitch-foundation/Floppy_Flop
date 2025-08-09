extends Node2D

@onready var player: Node2D = $player
@onready var spawn_point: Marker2D = $SpawnPoint

func _ready() -> void:
	player.global_position = spawn_point.global_position
