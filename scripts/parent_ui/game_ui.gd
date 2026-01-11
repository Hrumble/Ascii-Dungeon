class_name MainGameUI extends CanvasLayer

const _PRE_LOG : String = "GameUI> "

@export_subgroup("Buttons")
@export var _inventory_button : Button

@export_subgroup("Windows")
@export var log_handler : LogHandler
@export var picker_ui : PickerUI
@export var telescope_ui : TelescopeUI
@export var context_menu_scene : PackedScene
@export var _dialogue_window : WindowContainer
@export var _item_info_window : WindowContainer
@export var _inventory_window : WindowContainer

var _dialogue_system : DialogueManager
var _command_handler : CommandHandler
var _player_manager : PlayerManager
var _room_handler : RoomHandler
var _player : MainPlayer

func _ready():
	_dialogue_system = GameManager.get_dialogue_manager()
	_command_handler = GameManager.get_command_handler()
	_player_manager = GameManager.get_player_manager()
	_room_handler = GameManager.get_room_handler()
	_player = _player_manager.player

	# Connections
	_dialogue_system.dialogue_started.connect(show_dialogue)

	# _player_manager.entered_new_room.connect(on_enter_new_room)
	# _player_manager.entered_visited_room.connect(on_enter_visited_room)

	_inventory_button.pressed.connect(func(): _inventory_window.toggle())
	
	_dialogue_window.close()

## Shows a dialogue log.
func show_dialogue():
	_dialogue_window.open()

## Displays a new log on screen if able to.
## Ensures the log is allowed to print based on PlayerState.
func new_log(_log : Log):
	log_handler.add_log(_log)

#--------------------------------------------------------------------#
#                              Open UIs                              #
#--------------------------------------------------------------------#

## Opens the picker, the options must be printable, must be awaited for result
func open_picker(options : Array, title : String) -> int:
	picker_ui.set_up(options, title)
	var picked_option : int = await picker_ui.option_picked
	return picked_option

## Opens a new context menu at position `position`, if null will by default open at mouse position.
## Two menus cannot coexist
func get_new_context_menu(position  = null) -> ContextMenu:
	var context_menu : ContextMenu = context_menu_scene.instantiate()
	add_child(context_menu)

	if position == null:
		context_menu.position = get_viewport().get_mouse_position()
	else:
		context_menu.position = position

	context_menu.show()
	return context_menu

func open_item_information(item : Item):
	_item_info_window.open([item])

## Opens telescope, must be awaited for result
## Returns null if user escaped
func open_telescope(options : Array[TelescopeOption]):
	telescope_ui.open(options)
	var value = await telescope_ui.on_close
	return value

## When the player types something, if it's in a dialogue, then call the next object
# func _on_player_input(text : String):
# 	_log_player_input(text)
# 	if _dialogue_system.is_dialogue:
# 		_dialogue_system.next_object()
# 		return
# 	var result = await _command_handler.handle_command(text)
# 	# If command could not be parsed
# 	if result == false:
# 		new_log(Log.new("", GlobalEnums.LogType.GAME_ERROR))

## Logs the player input to screen
# func _log_player_input(text : String):
# 	var _log : Log = Log.new()
# 	_log.log_type = GlobalEnums.LogType.PLAYER_INPUT
# 	_log.description = text
# 	_log.override_allowed = true
# 	new_log(_log)
