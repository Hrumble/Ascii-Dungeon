class_name Command

var function : String
var args

## Parses a string into a command object
static func fromString(string : String) -> Command:
	var command_arr : Array = string.split(" ")
	var command : Command = Command.new()
	command.function = command_arr[0]
	var arguments : Array = []
	if command_arr.size() > 1:
		for arg in command_arr.slice(1, command_arr.size()):
			arguments.append(str(arg))

	command.args = arguments	

	return command
		

func _to_string() -> String:
	return "Command [function : %s, args : %s]" % [function, str(args)]
	
