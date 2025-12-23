class_name Minimap extends Control

@export var tilemap : TileMapLayer
@export var _texture_generator : RoomTextureGenerator
@export var _minimap_viewport : MinimapViewport
@export var _display_surface : TextureRect

var _tileset : TileSet
var _room_handler : RoomHandler
var _player_manager : PlayerManager

func initialize():
	_texture_generator.initialize()
	_minimap_viewport.initialize()
	_tileset = tilemap.tile_set
	_room_handler = GameManager.get_room_handler()
	_player_manager = GameManager.get_player_manager()

	_player_manager.entered_room.connect(_display_and_generate_texture)

func _ready():
	var tile_size = tilemap.tile_set.tile_size
	custom_minimum_size = tile_size * 6

## Displays the generated room texture on screen
func _display_and_generate_texture(room_pos : Vector2i):
	var room = _room_handler.get_room(room_pos)
	var room_texture_id = await _texture_generator.generate_room_texture(room)
	room_pos = Vector2i(room_pos.x, -room_pos.y)
	tilemap.set_cell(room_pos, room_texture_id, Vector2i(0, 0))
	var new_texture : ImageTexture = await _minimap_viewport.get_position_render(room_pos)
	_display_surface.texture = new_texture
