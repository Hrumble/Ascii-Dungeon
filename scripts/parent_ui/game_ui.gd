class_name MainGameUI extends CanvasLayer

const _PRE_LOG : String = "GameUI> "

@export var line_input : LineEdit
@export var log_handler : LogHandler
@export var inventory_button : Button
@export var minimap : Minimap
@export var picker_ui : PickerUI
@export var inventory_ui : InventoryUI
@export var fight_ui : FightUI

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
	minimap.initialize()

	_player.entered_new_room.connect(on_enter_new_room)
	_player.entered_visited_room.connect(on_enter_visited_room)

	_combat_manager.fight_started.connect(_on_fight_started)
	_combat_manager.fight_ended.connect(_on_fight_ended)

	line_input.player_enter.connect(_on_player_input)

func _on_fight_started(_oponent : Entity):
	fight_ui.open()

func _on_fight_ended(_oponent : Entity, _player_won : bool):
	fight_ui.close()

## Shows a dialogue log.
func show_dialogue():
	var _log : Log = Log.new("???", _dialogue_system.current_object.text , GlobalEnums.LogType.DIALOGUE)
	new_log(_log)

## Handles room entry and exit
func on_enter_new_room(_pos : Vector2i):
	var room_description : String = _room_handler.get_room_description(_player.current_room)
	new_log(Log.new("Room Entered", room_description))

func on_enter_visited_room(_pos : Vector2i):
	if (_player_manager.current_state == GlobalEnums.PlayerState.IN_DIALOGUE):
		return
	var path_description : String = _room_handler.get_room(_player.current_room)._generate_paths_description("")
	new_log(Log.new("", "You've been here before %s" % path_description))

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
		Logger.log_i(_PRE_LOG + "Cannot print log now, discarding")

## Opens the picker, the options must be printable, must be awaited for result
func open_picker(options : Array, title : String) -> int:
	picker_ui.set_up(options, title)
	var picked_option : int = await picker_ui.option_picked
	line_input.grab_focus()
	return picked_option

func open_inventory():
	inventory_ui.open()
	await inventory_ui.inventory_closed
	line_input.grab_focus()

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
