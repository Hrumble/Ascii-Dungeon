class_name Log extends Node

var title : String
var description : String
var log_type : LogType

## The type of the log
enum LogType {
	NORMAL,
	DIALOGUE,
	PLAYER_INPUT,
}

## Creates a new default log, can specify log type here.
func _init(_title : String = "", _description : String = "", _log_type : LogType = LogType.NORMAL):
	title = _title
	description = _description
	log_type = _log_type

## Creates a new dialogue log
static func new_dialogue_log():
	pass

