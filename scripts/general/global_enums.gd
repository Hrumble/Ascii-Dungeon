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

enum FIGHT_INTENTS {
	ATTACK,
	IDLE,
	BLOCK
}

enum EQUIPMENT_SLOTS {
	HEAD,
	CHEST,
	LEGS,
	FEET,
	R_HAND,
	L_HAND,
	BELT,
}

var busy_error_log : Log = Log.new("You are doing something!", LogType.GAME_ERROR)

