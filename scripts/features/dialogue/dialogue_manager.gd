class_name DialogueManager extends Node

var _pre_log : String = "DialogueManager> "

var current_dialogue : Dialogue
var previous_dialogue : Dialogue
## The current dialogue object
var current_object : DialogueObject
var previous_object : DialogueObject
## If there is currently a dialogue
var is_dialogue : bool = false

var _dialogue_object_index : int = 0
var _player_manager : PlayerManager

signal dialogue_started
signal dialogue_next_object
signal dialogue_ended

signal dialogue_system_ready

func initialize():
	Logger.log_i(_pre_log + "Initializing...")
	_player_manager = GameManager.get_player_manager()
	await get_tree().process_frame
	Logger.log_i(_pre_log + "Done")
	dialogue_system_ready.emit()

func _on_start_dialogue():
	Logger.log_i(_pre_log + "Starting dialogue...")
	_dialogue_object_index = 0
	current_object = current_dialogue.dialogue_objects[_dialogue_object_index]
	is_dialogue = true
	_player_manager.set_state(GlobalEnums.PlayerState.IN_DIALOGUE)
	dialogue_started.emit()
	_handle_event()

## Attemps to terminate the current dialogue
func end_current_dialogue():
	if current_dialogue != null:
		Logger.log_i(_pre_log + "Ending dialogue...")
		previous_dialogue = current_dialogue
		current_dialogue = null
		current_object = null
		is_dialogue = false
		_player_manager.set_to_previous_state()
		dialogue_ended.emit()
		return
	Logger.log_w(_pre_log + "Attempted to end the current dialogue, but there is none !")

## Starts a new specified dialogue
func start_dialogue_by_name(entity_name : String, dialogue_name : String):
	if !_load_dialogue_by_name(entity_name, dialogue_name):
		Logger.log_e(_pre_log + "Failed to start dialogue")
		return
	_on_start_dialogue()

## Starts a random dialogue that belongs to `entity_name`
func start_random_dialogue(entity_name : String):
	if !_load_random_dialogue(entity_name):
		Logger.log_e(_pre_log + "Failed to start dialogue")
		return
	_on_start_dialogue()

## Gets the next object of the dialogue, or ends the dialogue if there are none.
func next_object():
	if current_dialogue == null:
		Logger.log_e(_pre_log + "Attempted to call next object, but there is no dialogue!")
		return
	_dialogue_object_index += 1
	if current_dialogue.dialogue_objects.size() <= _dialogue_object_index:
		end_current_dialogue()
		return
	previous_object = current_object
	current_object = current_dialogue.dialogue_objects[_dialogue_object_index]
	dialogue_next_object.emit()
	_handle_event()

## If there is a specified event, trigger it.
func _handle_event():
	if current_object.has_event:
		GameManager.get_dialogue_event_manager().trigger_event(current_object.event, current_object.event_params)

## Loads a specific dialogue into current_dialogue
func _load_dialogue_by_name(entity_name : String, dialogue_name : String) -> bool:
	var dial : Dialogue = GameManager.get_dialogue_datasource().get_dialogue_by_name(entity_name, dialogue_name)
	if dial == null:
		Logger.log_e(_pre_log + "There was an error loading the dialogue: " + dialogue_name)
		return false
	_load_dialogue(dial)
	return true

## Sets a dialogue as current dialogue
func _load_dialogue(dialogue : Dialogue):
	if current_dialogue != null:
		previous_dialogue = current_dialogue
	current_dialogue = dialogue
	Logger.log_i(_pre_log + "Current dialogue set")
		

## Loads a random dialogue
func _load_random_dialogue(entity_name : String) -> bool:
	var dial : Dialogue = GameManager.get_dialogue_datasource().get_random_dialogue_from(entity_name)
	if dial == null:
		Logger.log_e(_pre_log + "Error occured while trying to load a random dialogue")
		return false
	_load_dialogue(dial)
	return true


	

	
