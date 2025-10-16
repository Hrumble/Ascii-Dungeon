class_name Log extends Node

var title : String
var description : String
var log_type : GlobalEnums.LogType
var override_allowed : bool

## Declares the allowed player states for each log type
static var allowed_logs : Dictionary[GlobalEnums.LogType, Array] = {
	GlobalEnums.LogType.NORMAL: [GlobalEnums.PlayerState.WANDERING],
	GlobalEnums.LogType.DIALOGUE: [GlobalEnums.PlayerState.IN_DIALOGUE],
}

## Creates a new default log, can specify log type here.
## 
## `_override_allowed` makes the log print even if the player state is not usually allowing it.
func _init(_title : String = "", _description : String = "", _log_type : GlobalEnums.LogType = GlobalEnums.LogType.NORMAL, _override_allowed : bool = false):
	title = _title
	description = _description
	log_type = _log_type
	override_allowed = _override_allowed

## Creates a new dialogue log
static func new_dialogue_log():
	pass

