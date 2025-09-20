class_name LogHandler extends Node

@export var log_item_scene : PackedScene
@export var logs_container : Control
@export var parent_scroll_container : ScrollContainer

# Array of Log
var log_history : Array
var _log_item_history : Array
const MAX_LOGS : int = 30

# Takes care of autoscrolling
var _previous_container_height : float

var _dialogue_system : DialogueManager

func _ready():
	_dialogue_system = GameManager.get_dialogue_manager()
	_previous_container_height = logs_container.size.y
	_dialogue_system.dialogue_started.connect(show_dialogue)
	_dialogue_system.dialogue_next_object.connect(show_dialogue)

## Adds a new log to screen
func add_log(_log : Log):
	_create_log(_log)
	pass

func _create_log(_log : Log):
	# Adds the log to the history
	log_history.append(_log)

	# Instantiates the log item
	var log_item : LogItem = log_item_scene.instantiate()
	_log_item_history.append(log_item)
	if _log_item_history.size() >= MAX_LOGS:
		_log_item_history[0].queue_free()
		_log_item_history.remove_at(0)
	# Childs it to the log container
	logs_container.add_child(log_item)

	log_item.set_log(_log)

func _process(delta):
	# If the height of the log container changes, scroll to the bottom
	if _previous_container_height != logs_container.size.y:
		parent_scroll_container.scroll_vertical=9999
		_previous_container_height = logs_container.size.y
	
## Adds a log containing the current dialogue object
func show_dialogue():
	var _log : Log = Log.new("???", _dialogue_system.current_object.text , Log.LogType.DIALOGUE)
	add_log(_log)
	pass
