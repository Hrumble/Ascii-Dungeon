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
	HEAD, #0
	CHEST, #1
	LEGS, #2
	FEET, #3
	R_HAND, #4
	L_HAND, #5
	R_FINGER_0, #6
	R_FINGER_1, #7
	L_FINGER_0, #8
	L_FINGER_1, #9
	BELT, #10
}

#--------------------------------------------------------------------#
#                            GENERAL LOGS                            #
#--------------------------------------------------------------------#

var busy_error_log : Log = Log.new("You are doing something!", LogType.GAME_ERROR)

