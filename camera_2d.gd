extends Camera2D

@export var left_limit: float = -480.0
@export var right_limit: float = 336.0

const VERTICAL_SPEED: float = 50.0  

func _process(delta):
	
	position.y += VERTICAL_SPEED * delta

	
	position.x = clamp(position.x, left_limit, right_limit)
