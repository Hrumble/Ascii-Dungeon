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

enum RARITY {
	COMMON = 1,
	UNCOMMON = 2,
	RARE = 3,
	UNHEARD = 4,
	INSANELY_RARE = 5
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
#                            Dictionaries                            #
#--------------------------------------------------------------------#

var equipment_slot_names : Dictionary[EQUIPMENT_SLOTS, String] = {
	EQUIPMENT_SLOTS.HEAD : "HEAD", #0
	EQUIPMENT_SLOTS.CHEST : "CHEST", #1
	EQUIPMENT_SLOTS.LEGS : "LEGS", #2
	EQUIPMENT_SLOTS.FEET : "FEET", #3
	EQUIPMENT_SLOTS.R_HAND : "R_HAND", #4
	EQUIPMENT_SLOTS.L_HAND : "L_HAND", #5
	EQUIPMENT_SLOTS.R_FINGER_0 : "R_FINGER_0", #6
	EQUIPMENT_SLOTS.R_FINGER_1 : "R_FINGER_1", #7
	EQUIPMENT_SLOTS.L_FINGER_0 : "L_FINGER_0", #8
	EQUIPMENT_SLOTS.L_FINGER_1 : "L_FINGER_1", #9
	EQUIPMENT_SLOTS.BELT : "BELT", #10
}

var rarity_names : Dictionary[RARITY, String] = {
	RARITY.COMMON : "Common",
	RARITY.UNCOMMON : "Uncommon",
	RARITY.RARE : "Rare",
	RARITY.INSANELY_RARE : "Insanely Rare",
	RARITY.UNHEARD : "Unheard",
}

var rarity_colors : Dictionary[RARITY, Color] = {
	RARITY.COMMON : Color.WHITE,
	RARITY.UNCOMMON : Color.LIGHT_GREEN,
	RARITY.RARE : Color.BLUE,
	RARITY.INSANELY_RARE : Color.PURPLE,
	RARITY.UNHEARD : Color.RED,
}

#--------------------------------------------------------------------#
#                            GENERAL LOGS                            #
#--------------------------------------------------------------------#

var busy_error_log : Log = Log.new("You are doing something!", LogType.GAME_ERROR)

