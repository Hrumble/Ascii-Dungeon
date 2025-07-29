class_name ProgressionSystem extends Node

const _steps_file : String = "res://progression/steps.json"
const _pre_log : String = "ProgressionSystem> "

signal progression_system_ready

var steps : Dictionary 
## Gets called when a step is marked as completed, does not get called if the step was already completed
signal step_completed(step_id : String)

func initialize():
	_load_progression_steps(_steps_file)
	Logger.log_i(_pre_log + "Loaded steps are : " + str(steps))
	pass

## Fetches all the steps inside the `file_path` var. Initializes them to be false (not completed)
func _load_progression_steps(file_path : String):
	var steps_json : String = FileAccess.get_file_as_string(file_path)
	if steps_json == "":
		Logger.log_e(_pre_log + "Failed to open the file : " + file_path)
		steps = {}
		return
	var parsed_json : Dictionary = JSON.parse_string(steps_json)
	
	# For each step, set the name as id and the status to false (not done)
	for s in parsed_json["steps"]:
		steps[s] = false
	await get_tree().process_frame
	progression_system_ready.emit()
	

## Checks wether step with id `id` is completed. Returns false if the step does not exist
func is_step_completed(id : String) -> bool:
	if !steps.has(id):
		Logger.log_e(_pre_log + "Step with id %s could not be found" % id)
		return false
	else:
		return steps[id]

## Completes a step with id `id`. If the step was already completed, nothing changes
func complete_step(id : String):
	if !steps.has(id):
		Logger.log_e(_pre_log + "Step with id (%s) could not be found" % id)
		return
	else:
		if !steps[id]:
			steps[id] = true
			step_completed.emit()
		else:
			steps[id] = true
		Logger.log_i(_pre_log + "Step with id (%s) set to completed" % id)
		
