class_name Minimap extends Node2D

@export var tilemap : TileMapLayer
@export var selection_tilemap : TileMapLayer
@export var debug_tilemap : TileMapLayer

@export var _texture_generator : RoomTextureGenerator

var _tileset : TileSet
var _room_handler : RoomHandler
var _player_manager : PlayerManager
var _is_in_context : bool = false
var current_selected_square : Vector2i

func _ready():
	_texture_generator.initialize()
	_tileset = tilemap.tile_set
	_room_handler = GameManager.get_room_handler()
	_player_manager = GameManager.get_player_manager()
	_player_manager.entered_room.connect(_display_and_generate_texture)

	_room_handler.room_generated.connect(_on_room_generated)

## Solely for debug, shows generated rooms
func _on_room_generated(_pos : Vector2i):
	for pos in _room_handler.generated_rooms.keys():
		debug_tilemap.set_cell(pos, 0, Vector2i(0, 0))
	pass

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if _is_in_context:
			return
		var new_selected_square : Vector2i = selection_tilemap.local_to_map(selection_tilemap.get_local_mouse_position())
		# Skip updating if it's still the same square
		if new_selected_square != current_selected_square:
			current_selected_square = new_selected_square
			_update_current_selected_square()

	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_RIGHT:
			_is_in_context = true
			var context_menu : ContextMenu = GameManager.get_ui().get_new_context_menu()
			context_menu.add_text_option("_context_enter_room", "Enter Room")
			context_menu.add_text_option("_context_peek", "Peek")

			context_menu.on_pressed.connect(func(v): call(v))
			context_menu.on_close.connect(func(): _is_in_context = false)

func _context_enter_room():
	_player_manager.enter_room(current_selected_square)
		
func _update_current_selected_square():
	selection_tilemap.clear()
	selection_tilemap.set_cell(current_selected_square, 0, Vector2i(0, 0))

## Displays the generated room texture on screen
func _display_and_generate_texture(room_pos : Vector2i):
	var room = _room_handler.get_room(room_pos)
	var room_texture_id = await _texture_generator.generate_room_texture(room)
	room_pos = Vector2i(room_pos.x, room_pos.y)
	tilemap.set_cell(room_pos, room_texture_id, Vector2i(0, 0))
