class_name LogHandler extends Node

@export var logs_container: Control
@export var parent_scroll_container: ScrollContainer

# Array of Log
var log_history: Array
var _log_item_history: Array
const MAX_LOGS: int = 30

# Takes care of autoscrolling
var _previous_container_height: float

var _dialogue_system: DialogueManager


func _ready():
	_dialogue_system = GameManager.get_dialogue_manager()
	_previous_container_height = logs_container.size.y


## Adds a new log to screen
func add_log(_log: Log):
	_create_log(_log)
	pass

func _create_log(_log: Log):
	# Adds the log to the history
	log_history.append(_log)

	# Instantiates the log item
	var log_item: RichTextLabel = _get_log_item(_log)

	_log_item_history.append(log_item)

	if _log_item_history.size() >= MAX_LOGS:
		_log_item_history[0].queue_free()
		_log_item_history.remove_at(0)

	# Childs it to the log container
	logs_container.add_child(log_item)

func _get_log_item(_log : Log) -> Control:
	var label : RichTextLabel = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.modulate = Color(1, 1, 1, .7)
	label.theme_type_variation = "RichLabelExtraSmall"
	label.text = "[%s] " % Time.get_time_string_from_system()

	if _log.log_type == GlobalEnums.LogType.GAME_ERROR:
		label.text += "[color=red]%s[/color]" % _log.text
	else:
		label.text += _log.text

	return label


func _process(_delta):
	# If the height of the log container changes, scroll to the bottom
	if _previous_container_height != logs_container.size.y:
		parent_scroll_container.scroll_vertical = 9999
		_previous_container_height = logs_container.size.y
