class_name MapContainer extends GridContainer


## Displays the map on screen, a grid of `_size`x`_size` [PanelContainers]
func generate_map(_size : int):
	columns = _size
	for x in _size:
		for y in _size:
			var map_square : MapSquareContainer = MapSquareContainer.new()
			map_square.custom_minimum_size = Vector2i(64, 64)
			add_child(map_square)

