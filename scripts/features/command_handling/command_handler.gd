## Class that takes care of handling user input and executing the correct commands.
## A function that the user can call should be prefixed with COMMAND_PREFIX.
## 
## All function arguments must be String, convert as necessary inside the function.
class_name CommandHandler extends Node

const COMMAND_PREFIX : String = "cmd_"
const  _pre_log : String = "CommandHandler> "

var _player : MainPlayer
var _room_handler : RoomHandler
var _registry : Registry

signal command_handler_ready

## `error` is a string that is set with the current error of `handle_command`, if any
var error : String = ""

## Holds a dictionnary matching function name with n of required arguments
var _available_commands : Dictionary = {}

func initialize():
	Logger.log_i(_pre_log + "Initializing...")
	_player = GameManager.get_player_manager().player
	_room_handler = GameManager.get_room_handler()
	_registry = GameManager.get_registry()
	_initialize_commands()

func _initialize_commands():
	for method in get_method_list():
		var func_name : String = method["name"]
		if func_name.begins_with(COMMAND_PREFIX):
			# Seems roundabout but trust me
			# Each command is listed in a dictionnary that follows func_name : [n of all args, n of REQUIRED args]
			# The n of required args is necessary, to not softlock the player if he inputs an amount of args below the optional ones
			var n_all_args : int = method["args"].size()
			var n_necessary_args : int = n_all_args - method["default_args"].size()
			_available_commands[func_name] = [n_all_args, n_necessary_args]

	Logger.log_i(_pre_log + "Loaded commands are : " + str(_available_commands))
	await get_tree().process_frame
	Logger.log_i(_pre_log + "Done")
	command_handler_ready.emit()

## Handles the user input command, returns true if it was executed, false if not
## For this reason EVERY SINGLE COMMAND must return a bool.
func handle_command(input : String) -> bool:
	input = input.to_lower()
	var command : Command = Command.fromString(input)
	Logger.log_i(_pre_log + "User parsed command: "+ str(command))
	var full_function_name : String = COMMAND_PREFIX + command.function 
	if !full_function_name in _available_commands:
		Logger.log_w(_pre_log + "Command %s does not exist" % command.function)
		error = "Command %s does not exist" % command.function
		return false
	# Checks if command is above Necessary n of args, and not above max args
	if _available_commands[full_function_name][1] > command.args.size() or _available_commands[full_function_name][0] < command.args.size():
		Logger.log_w(_pre_log + "Command %s expected more or less arguments" % command.function)
		error = "Command %s expected more or less arguments" % command.function
		return false
	if command.args == null:
		return await call(COMMAND_PREFIX + command.function)
	else:
		return await callv(COMMAND_PREFIX + command.function, command.args)

## Returns a list of all commands starting with `text`
func commands_start_with(text : String) -> Array[String]:
	text = text.to_lower()
	var possible_commands : Array[String]
	for cmd : String in _available_commands.keys():
		cmd = cmd.substr(COMMAND_PREFIX.length())
		if text in cmd:
			possible_commands.append(cmd)
	return possible_commands

## A sample callable command for the user, can be called with "test_command" in game.
func cmd_test_command(arg1 : String) -> bool:
	print("Test command called with arg: ", arg1)
	return true

## Gives a specified item_id to the player
func cmd_give(item_id : String, amount : String = "1") -> bool:
	# If player did not pass an int as amount
	if !amount.is_valid_int():
		error = "Give expects an item ID and an amount, see: give <item_id> [amount=1]"
		return false
	_player.add_item_to_inventory(item_id, amount.to_int())
	return true

## Moves the player through an available doorway
func cmd_move(_dir: String) -> bool:
	var direction : String = _dir.to_upper()
	match direction:
		"FRONT":
			return _move_to_room(_room_handler.room_get_path(_player.current_room, GlobalEnums.PATH_ID.FRONT))	
		"BACK":
			return _move_to_room(_room_handler.room_get_path(_player.current_room, GlobalEnums.PATH_ID.BACK))	
		"LEFT":
			return _move_to_room(_room_handler.room_get_path(_player.current_room, GlobalEnums.PATH_ID.LEFT))	
		"RIGHT":
			return _move_to_room(_room_handler.room_get_path(_player.current_room, GlobalEnums.PATH_ID.RIGHT))	
		_:
			error = "move expects a valid direction: move <FRONT|BACK|LEFT|RIGHT> (case_insensitive)"
			return false

## Inner function used to avoid code repetition, attempts to enter room if path is valid
func _move_to_room(room_pos) -> bool:
	if room_pos == null:
		error = "There is no path here!"
		return false
	_player.enter_room(room_pos)
	return true

func cmd_interact() -> bool:
	var room_entities : Array = _room_handler.get_room(_player.current_room).instantiated_entities
	var arr : Array = []
	if room_entities.size() < 1:
		error = "There is nothing to interact with here..."
		return false
	else:
		arr = room_entities.map(func(e): return e.display_name)

	var opt : int = await GameManager.get_ui().open_picker(arr, "What are you interacting with")
	Logger.log_d(_pre_log + "Picked option is: %s" %opt)
	if opt == -1:
		return true

	room_entities[opt].interact()
	return true

func cmd_attack() -> bool:
	var room_entities : Array = _room_handler.get_room(_player.current_room).instantiated_entities
	var arr : Array = []
	if room_entities.size() < 1:
		error = "You're swinging mindlessly at the air, there is nothing here."
		return false
	else:
		arr = room_entities.map(func(e): return e.display_name)
	
	var opt : int = await GameManager.get_ui().open_picker(arr, "What are you attacking")
	Logger.log_d(_pre_log + "Picked option is: %s" %opt)
	if opt == -1:
		return true
	room_entities[opt].on_attacked()
	return true

func cmd_inventory() -> bool:
	await GameManager.get_ui().open_inventory()
	return true

## Redescribes the current room
func cmd_describe() -> bool:
	GameManager.get_ui().new_log(Log.new("", _room_handler.get_room_description(_player.current_room)))
	return true
		
func cmd_help() -> bool:
	GameManager.get_ui().new_log(Log.new("HELP", '''
In the game, you move around and interact with the world using commands, each command can take arguments.
If you don't know the usage for a specific command, type `help <command>`

here are some basic commands:

- move <FRONT|BACK|LEFT|RIGHT>
- describe
- interact
- attack
	'''))
	return true
