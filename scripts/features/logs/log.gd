class_name Log extends Node

var text : String
var log_type : GlobalEnums.LogType
var override_allowed : bool

## Creates a new log, can specify log type here.
func _init(_text : String = "", _log_type : GlobalEnums.LogType = GlobalEnums.LogType.NORMAL):
	text = _text
	log_type = _log_type
