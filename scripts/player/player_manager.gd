class_name PlayerManager extends Node

signal player_manager_ready
const _PRE_LOG : String = "PlayerManager> "
var player : MainPlayer
var turns : float

var current_state : GlobalEnums.PlayerState
var previous_state : GlobalEnums.PlayerState

var current_room : Room
var previous_room : Room

## Gets called when the player enters a new room
signal entered_new_room(room_pos: Vector2i)
## The player enters a room he's been in before
signal entered_visited_room(room_pos: Vector2i)
## The player enters a room, wether visited or not
signal entered_room(room_pos: Vector2i)
## The player state has changed
signal state_changed(state: GlobalEnums.PlayerState)

## The rooms the player has previously been to. Does not include the current room
var visited_rooms: Array[Vector2i]

func initialize():

	# Initializes player
	player = MainPlayer.new()
	player.initialize()

	current_state = GlobalEnums.PlayerState.WANDERING
	previous_state = GlobalEnums.PlayerState.IN_DIALOGUE
	turns = 0.0

	await get_tree().process_frame
	GlobalLogger.log_i(_PRE_LOG + "Done")
	player_manager_ready.emit()


## Enters a room, the room must exist and the player must be in a wandering state
func enter_room(room_pos: Vector2i):
	if current_state != GlobalEnums.PlayerState.WANDERING:
		GameManager.get_ui().new_log(GlobalEnums.busy_error_log)
		return

	if current_room != null and room_pos == current_room.position:
		GlobalLogger.log_w(_PRE_LOG + "Cannot enter room %s, player is already in it" % room_pos)
		return

	GlobalLogger.log_i(_PRE_LOG + "Player entering room %s " % room_pos)

	previous_room = current_room
	current_room = GameManager.get_room_handler().get_room(room_pos)

	if current_room == null:
		GlobalLogger.log_e(_PRE_LOG + "Failed to enter room %s, room does not exist." % room_pos)
		return
	if room_pos in visited_rooms:
		entered_visited_room.emit(room_pos)
	else:
		visited_rooms.append(room_pos)
		entered_new_room.emit(room_pos)
	entered_room.emit(room_pos)
	turns += 1.0

## Sets the current state of the player
func set_state(new_state : GlobalEnums.PlayerState):
	GlobalLogger.log_i(_PRE_LOG + "Changing player state to " + str(new_state))
	previous_state = current_state
	current_state = new_state
	state_changed.emit(current_state)

## Sets the state back to the one from before. Is there was no previous state, sets WANDERING to default
## Does not change the previous state to avoid toggling
func set_to_previous_state():
	if previous_state == null:
		current_state = GlobalEnums.PlayerState.WANDERING
	else:
		current_state = previous_state
	
	state_changed.emit(current_state)
