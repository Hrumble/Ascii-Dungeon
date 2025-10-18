class_name LogItem extends Node

# Containers
@export var description_container : Control

# Labels
@export var title_label : Label
@export var description_label : RichTextLabel
@export var player_input_label : Label

@export var timer : Timer
signal done_displaying


## Shows a log on screen, the log will differ based on the type of log
func set_log(_log : Log):
	# Hides everything
	title_label.hide()
	description_container.hide()
	player_input_label.hide()

	## Based on log type, the log appears differently
	if _log.log_type == GlobalEnums.LogType.NORMAL:
		_set_normal_log(_log)
	if _log.log_type == GlobalEnums.LogType.DIALOGUE:
		_set_dialogue_log(_log)
	if _log.log_type == GlobalEnums.LogType.PLAYER_INPUT:
		_set_player_input_log(_log)

	# Below is used for specific messages from the game itself
	if _log.log_type == GlobalEnums.LogType.GAME_ERROR:
		_set_game_error_log(_log)

	if _log.log_type == GlobalEnums.LogType.GAME_INFO:
		_set_game_info_log(_log)

func _set_game_info_log(_log : Log):
	title_label.hide()
	description_container.show()
	description_label.text = _log.description
	description_label.theme_type_variation = "InfoLabel"

func _set_game_error_log(_log : Log):
	title_label.hide()
	description_container.show()
	description_label.text = _log.description
	description_label.theme_type_variation = "ErrorLabel"
	pass

func _set_dialogue_log(_log : Log):
	description_container.show()
	description_label.text = _log.description	

	description_label.visible_characters = 0
	timer.one_shot = false
	for letter in _log.description:
		if letter == ",":
			timer.wait_time = .1
		elif letter in [".", "!", "?"]:
			timer.wait_time = .5
		else:
			timer.wait_time = .01
		description_label.visible_characters += 1
		timer.start()
		await timer.timeout

	done_displaying.emit()

func _set_player_input_log(_log : Log):
	player_input_label.show()
	player_input_label.text = _log.description
	pass

func _set_normal_log(_log : Log):
	title_label.show()
	description_container.show()

	# If no description is specified, just hide the description container
	if _log.description == "":
		description_container.hide()
	else:
		description_label.text = _log.description
	title_label.text = _log.title
	done_displaying.emit()
	pass
