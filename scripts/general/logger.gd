extends Node

var logging_enabled = true
var debug : bool = false

# CONST
const _INFO_PRE = "[INFO]"
const _WARNING_PRE = "[WARNING]"
const _ERROR_PRE = "[ERROR]"
const _DEBUG_PRE = "[DEBUG]"

func _print_log(log_str : String):
	if logging_enabled:
		print("[%s] " % Time.get_time_string_from_system() + log_str)

## Logs an INFO to console
func log_i(log_str : String):
	_print_log(_INFO_PRE + " " + log_str)

## Logs an WARNING to console
func log_w(log_str : String):
	_print_log(_WARNING_PRE + " " + log_str)

## Logs an ERROR to console
func log_e(log_str : String):
	_print_log(_ERROR_PRE + " " + log_str)

## Prints a log in debug, if debug is false, these will not show
func log_d(log_str : String):
	if debug:
		_print_log(_DEBUG_PRE + " " + log_str)
	
