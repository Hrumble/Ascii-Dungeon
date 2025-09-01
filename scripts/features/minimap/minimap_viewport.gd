class_name MinimapViewport extends SubViewport

@export var minimap_camera : Camera2D
@export var minimap_tilemap : TileMapLayer

var tile_size : Vector2

func initialize(viewport_size : Vector2 = Vector2(128, 128)):
	disable_3d = true
	size = viewport_size
	transparent_bg = true
	tile_size = Vector2(minimap_tilemap.tile_set.tile_size.x, minimap_tilemap.tile_set.tile_size.y)
	render_target_update_mode = SubViewport.UPDATE_ALWAYS

## Returns the minimap render of the current player position
func get_position_render(room_position : Vector2i) -> ImageTexture:
	var next_pos : Vector2 = minimap_tilemap.map_to_local(room_position)
	next_pos = minimap_tilemap.to_global(next_pos)
	print("map_to_local:", room_position, "  camera space:", minimap_camera.position)
	minimap_camera.position = next_pos

	await RenderingServer.frame_post_draw

	var image : Image = get_texture().get_image()
	var texture : ImageTexture = ImageTexture.create_from_image(image)

	return texture
