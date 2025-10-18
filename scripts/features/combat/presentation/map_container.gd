class_name MapContainer extends GridContainer

@export var _mapSquareScene : PackedScene

## Displays the map on screen, a grid of (`_size` x `_size`) [PanelContainers]
func generate_map(_size : int):
	columns = _size
	for x in _size:
		for y in _size:
			# Instantiates and sets up the map square
			var map_square : MapSquareContainer = _mapSquareScene.instantiate()
			map_square.setup(
				# Position of the square
				Vector2i(x, y),
			)
			# Adds it as a child
			add_child(map_square)

