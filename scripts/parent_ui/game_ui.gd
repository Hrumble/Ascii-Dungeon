class_name MainGameUI extends CanvasLayer

@export var log_handler : LogHandler
@export var line_input : LineEdit

@export var inventory_button : Button

var _dialogue_system : DialogueSystem
var _command_handler : CommandHandler

func _ready():
	_dialogue_system = GameManager.get_dialogue_system()
	_command_handler = GameManager.get_command_handler()

	line_input.player_enter.connect(_on_player_input)


## When the player types something, if it's in a dialogue, then call the next object
func _on_player_input(text : String):
	_log_player_input(text)
	if _dialogue_system.is_dialogue:
		_dialogue_system.next_object()
		return
	var result = _command_handler.handle_command(text)
	# If command could not be parsed
	if result == false:
		log_handler.add_log(Log.new("", _command_handler.error, Log.LogType.GAME_ERROR))

## Logs the player input to screen
func _log_player_input(text : String):
	var _log : Log = Log.new()
	_log.log_type = Log.LogType.PLAYER_INPUT
	_log.description = text
	log_handler.add_log(_log)
