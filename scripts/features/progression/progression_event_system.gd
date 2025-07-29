class_name ProgressionEventSystem
## This class is used to react to completed steps
## 
## Once a step is completed, it gets routed to the correct logic

var _progression_system : ProgressionSystem

func initialize():
	_progression_system = GameManager.get_progression_system()
	_progression_system.step_completed.connect(_on_step_completed)
	pass

## Executes when a step is marked as completed
func _on_step_completed(step_id : String):
	pass
