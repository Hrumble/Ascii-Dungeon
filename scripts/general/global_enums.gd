extends Node

enum PlayerState {
	WANDERING,
	IN_DIALOGUE,
	FIGHTING,
}

## The type of the log
enum LogType {
	NORMAL,
	DIALOGUE,
	PLAYER_INPUT,
	GAME_ERROR,
	GAME_INFO
}

enum PATH_ID {
	FRONT,
	BACK,
	LEFT,
	RIGHT
}

var busy_error_log : Log = Log.new("You are doing something!", LogType.GAME_ERROR)

