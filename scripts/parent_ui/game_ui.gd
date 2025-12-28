class_name MainGameUI extends CanvasLayer

const _PRE_LOG : String = "GameUI> "

@export var log_handler : LogHandler
@export var picker_ui : PickerUI
@export var inventory_ui : InventoryUI
@export var fight_ui : FightUI
@export var telescope_ui : TelescopeUI
@export var context_menu_scene : PackedScene

var _dialogue_system : DialogueManager
var _command_handler : CommandHandler
var _player_manager : PlayerManager
var _combat_manager : FightManager
var _room_handler : RoomHandler
var _player : MainPlayer

func _ready():
	_dialogue_system = GameManager.get_dialogue_manager()
	_command_handler = GameManager.get_command_handler()
	_player_manager = GameManager.get_player_manager()
	_combat_manager = GameManager.get_combat_manager()
	_room_handler = GameManager.get_room_handler()
	_player = _player_manager.player

	# Connections
	_dialogue_system.dialogue_started.connect(show_dialogue)
	_dialogue_system.dialogue_next_object.connect(show_dialogue)

	# _player_manager.entered_new_room.connect(on_enter_new_room)
	# _player_manager.entered_visited_room.connect(on_enter_visited_room)

	_combat_manager.fight_started.connect(_on_fight_started)
	_combat_manager.fight_ended.connect(_on_fight_ended)


func _on_fight_started(_oponent : Entity):
	fight_ui.open()

func _on_fight_ended(_oponent : Entity, _player_won : bool):
	fight_ui.close()

## Shows a dialogue log.
func show_dialogue():
	var _log : Log = Log.new("???", _dialogue_system.current_object.text , GlobalEnums.LogType.DIALOGUE)
	new_log(_log)

# ## Handles room entry and exit
# func on_enter_new_room(_pos : Vector2i):
# 	var room_description : String = _player_manager.current_room.get_room_description()
# 	new_log(Log.new("Room Entered", room_description))
#
# func on_enter_visited_room(_pos : Vector2i):
# 	if (_player_manager.current_state == GlobalEnums.PlayerState.IN_DIALOGUE):
# 		return
# 	# var path_description : String = _player_manager.current_room._generate_paths_description("")
# 	new_log(Log.new("", "You've been here before"))

## Displays a new log on screen if able to.
## Ensures the log is allowed to print based on PlayerState.
func new_log(_log : Log):
	if (_log.override_allowed or !Log.allowed_logs.has(_log.log_type)):
		log_handler.add_log(_log)
		return
	if (_player_manager.current_state in Log.allowed_logs[_log.log_type]):
		log_handler.add_log(_log)
		return
	else:
		GlobalLogger.log_i(_PRE_LOG + "Cannot print log now, discarding")

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

## Opens telescope, must be awaited for result
## Returns null if user escaped
func open_telescope(options : Array[TelescopeOption]):
	telescope_ui.open(options)
	var value = await telescope_ui.on_close
	return value

func open_inventory():
	inventory_ui.open()
	await inventory_ui.inventory_closed

## When the player types something, if it's in a dialogue, then call the next object
func _on_player_input(text : String):
	_log_player_input(text)
	if _dialogue_system.is_dialogue:
		_dialogue_system.next_object()
		return
	var result = await _command_handler.handle_command(text)
	# If command could not be parsed
	if result == false:
		new_log(Log.new("", _command_handler.error, GlobalEnums.LogType.GAME_ERROR))

## Logs the player input to screen
func _log_player_input(text : String):
	var _log : Log = Log.new()
	_log.log_type = GlobalEnums.LogType.PLAYER_INPUT
	_log.description = text
	_log.override_allowed = true
	new_log(_log)
