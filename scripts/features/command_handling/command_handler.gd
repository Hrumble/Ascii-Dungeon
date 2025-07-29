## Class that takes care of handling user input and executing the correct commands.
## A function that the user can call should be prefixed with COMMAND_PREFIX.
## 
## All function arguments must be String, convert as necessary inside the function.
class_name CommandHandler extends Node

const COMMAND_PREFIX : String = "cmd_"
const  _pre_log : String = "CommandHandler> "
signal command_handler_ready

## Holds a dictionnary matching function name with n of required arguments
var _available_commands : Dictionary = {}

func initialize():
	Logger.log_i(_pre_log + "Initializing...")
	_initialize_commands()

## Handles the user input command, returns true if it was executed, false if not
func handle_command(input : String) -> bool:
	input = input.to_lower()
	var command : Command = Command.fromString(input)
	Logger.log_i(_pre_log + "User parsed command: "+ str(command))
	var full_function : String = COMMAND_PREFIX + command.function 
	if !full_function in _available_commands:
		Logger.log_w(_pre_log + "Command %s does not exist" % command.function)
		return false
	if _available_commands[full_function] > command.args.size() or _available_commands[full_function] < command.args.size():
		Logger.log_w(_pre_log + "Command %s expected more or less arguments" % command.function)
		return false
	if command.args == null:
		call(COMMAND_PREFIX + command.function)
		return true
	else:
		callv(COMMAND_PREFIX + command.function, command.args)
		return true

## Returns a list of all commands starting with `text`
func commands_start_with(text : String) -> Array[String]:
	text = text.to_lower()
	var possible_commands : Array[String]
	for cmd : String in _available_commands.keys():
		cmd = cmd.substr(COMMAND_PREFIX.length())
		if text in cmd:
			possible_commands.append(cmd)
	return possible_commands

func _initialize_commands():
	for method in get_method_list():
		var func_name : String = method["name"]
		if func_name.begins_with(COMMAND_PREFIX):
			_available_commands[func_name] = method["args"].size()

	Logger.log_i(_pre_log + "Loaded commands are : " + str(_available_commands))
	await get_tree().process_frame
	command_handler_ready.emit()

## A sample callable command for the user, can be called with "test_command" in game.
func cmd_test_command(arg1 : String):
	print("Test command called with arg: ", arg1)

func cmd_give(amount : int = 1):
	GameManager.get_player().inventory.add_item("wooden_stick", amount)
