extends Node

func _ready():
	var layer0 = $Layer0
	var used_rect0 = layer0.get_used_rect()
	var left_tile_x0 = used_rect0.position.x
	var right_tile_x0 = used_rect0.position.x + used_rect0.size.x - 1
	
	var tileset0 = layer0.tile_set  
	var tile_size0 = tileset0.get_tile_size()
	
	var left_wall_x0 = layer0.global_position.x + left_tile_x0 * tile_size0.x
	var right_wall_x0 = layer0.global_position.x + right_tile_x0 * tile_size0.x
	print("Layer0 Left wall X:", left_wall_x0)
	print("Layer0 Right wall X:", right_wall_x0)

	var layer1 = $Layer1
	var used_rect1 = layer1.get_used_rect()
	var left_tile_x1 = used_rect1.position.x
	var right_tile_x1 = used_rect1.position.x + used_rect1.size.x - 1
	
	var tileset1 = layer1.tile_set  
	var tile_size1 = tileset1.get_tile_size()
	
	var left_wall_x1 = layer1.global_position.x + left_tile_x1 * tile_size1.x
	var right_wall_x1 = layer1.global_position.x + right_tile_x1 * tile_size1.x
	print("Layer1 Left wall X:", left_wall_x1)
	print("Layer1 Right wall X:", right_wall_x1)
