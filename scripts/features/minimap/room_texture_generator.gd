class_name RoomTextureGenerator extends Node

@export var tileset : TileSet
@export var _minimap_room_textures : MinimapRoomTextures
@export var _subviewport : SubViewport

var _tile_size : Vector2i = Vector2i(32, 32)

func initialize():
	_subviewport.size = _tile_size
	_subviewport.disable_3d = true
	_subviewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	pass

## Generates the appropriate texture for a provided room, returns the id of the tileset source created
func generate_room_texture(room : Room) -> int:
	_clear_children()
	_add_texture(_minimap_room_textures.base_room_texture, Vector2i.LEFT)
	if room.room_front != null:
		_add_texture(_minimap_room_textures.open_door_texture, Vector2i.UP)
	else:
		_add_texture(_minimap_room_textures.closed_door_texture, Vector2i.UP)

	if room.room_left != null:
		_add_texture(_minimap_room_textures.open_door_texture, Vector2i.LEFT)
	else:
		_add_texture(_minimap_room_textures.closed_door_texture, Vector2i.LEFT)

	if room.room_right != null:
		_add_texture(_minimap_room_textures.open_door_texture, Vector2i.RIGHT)
	else:
		_add_texture(_minimap_room_textures.closed_door_texture, Vector2i.RIGHT)

	if room.room_back != null:
		_add_texture(_minimap_room_textures.open_door_texture, Vector2i.DOWN)
	else:
		_add_texture(_minimap_room_textures.closed_door_texture, Vector2i.DOWN)

	return await _export_texture()

## Adds the texture as a child of generator, for subviewport to render later
func _add_texture(texture : Texture2D, orientation : Vector2i):
	var sprite : Sprite2D = Sprite2D.new()
	sprite.texture = texture
	sprite.position = _tile_size/2
	match orientation:
		Vector2i.UP:
			sprite.rotate(deg_to_rad(90))
		Vector2i.RIGHT:
			sprite.rotate(deg_to_rad(180))
		Vector2i.DOWN:
			sprite.rotate(deg_to_rad(-90))
	_subviewport.add_child(sprite)
	

## Sets the created viewport texture into the tileset, return the id of the created source
func _export_texture() -> int:
	# Ensures the viewport drew everything
	await RenderingServer.frame_post_draw
	# Pull the image from viewport, turn it into a texture
	# (we need to get the image first, getting only the texture returns a ViewportTexture which messes things up)
	var image : Image = _subviewport.get_texture().get_image()
	var texture : ImageTexture = ImageTexture.create_from_image(image)

	## Sets a new source in the tileset with the created texture
	var source : TileSetAtlasSource = TileSetAtlasSource.new()
	source.texture_region_size = _tile_size
	source.texture = texture
	source.create_tile(Vector2i(0, 0))
	var id : int = tileset.add_source(source)
		
	return id

func _clear_children():
	for c in _subviewport.get_children():
		c.queue_free()
		
