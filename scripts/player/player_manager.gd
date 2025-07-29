class_name PlayerManager extends Node

signal player_manager_ready
var _pre_log : String = "PlayerManager> "

enum PlayerState {
	WANDERING,
	IN_DIALOGUE,
	FIGHTING,
}

var current_state : PlayerState
var previous_state : PlayerState

func initialize():
	current_state = PlayerState.WANDERING
	previous_state = PlayerState.IN_DIALOGUE
	await get_tree().process_frame
	player_manager_ready.emit()

func set_state(new_state : PlayerState):
	Logger.log_i(_pre_log + "Changing player state to " + str(new_state))
	previous_state = current_state
	current_state = new_state

## Sets the state back to the one from before. Is there was no previous state, sets WANDERING to default
## Does not change the previous state to avoid toggling
func set_to_previous_state():
	if previous_state == null:
		current_state = PlayerState.WANDERING
	else:
		current_state = previous_state
