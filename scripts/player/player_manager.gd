class_name PlayerManager extends Node

@export var _player_scene : PackedScene

signal player_manager_ready
var _pre_log : String = "PlayerManager> "
var player : MainPlayer
var turns : float

enum PlayerState {
	WANDERING,
	IN_DIALOGUE,
	FIGHTING,
}

var current_state : PlayerState
var previous_state : PlayerState

func initialize():

	# Initializes player
	player = _player_scene.instantiate()
	player.initialize()
	add_child(player)

	current_state = PlayerState.WANDERING
	previous_state = PlayerState.IN_DIALOGUE
	turns = 0.0

	# Handles connections
	player.entered_new_room.connect(_on_enter_room)
	await get_tree().process_frame
	player_manager_ready.emit()

func _on_enter_room(_room_pos : Vector2i):
	turns += 1.0

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
