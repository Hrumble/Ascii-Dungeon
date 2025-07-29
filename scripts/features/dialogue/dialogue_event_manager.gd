class_name DialogueEventManager extends Node

signal dialogue_event_manager_ready

var _pre_log : String = "EventManager> "
var _main_ui : MainGameUI
var _progression_system : ProgressionSystem

func initialize():
	_main_ui = GameManager.get_ui()
	_progression_system = GameManager.get_progression_system()
	await get_tree().process_frame
	dialogue_event_manager_ready.emit()

## Triggers an event based on dialogue, if the [DialogueObject] has the "event" key
func trigger_event(event_name: String, event_params = null):
	if has_method(event_name):
		Logger.log_i(_pre_log + "Calling %s with params [%s]" % [event_name, event_params])
		if event_params != null:
			callv(event_name, event_params)
		else:
			call(event_name)
	else:
		Logger.log_e(_pre_log + "The event specified (%s) does not exist inside the EventManager")

func _deal_player_damage(dmg : float = 1.0):
	GameManager.get_player().take_damage(dmg)

func _show_inventory_button():
	_main_ui.inventory_button.show()

func _complete_progression_step(step_id : String):
	_progression_system.complete_step(step_id)
	pass
	
