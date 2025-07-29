extends LineEdit

signal player_enter(text : String)

@export var enter_button : Button
@export var autocomplete_container : Control
@export var autocomplete_item_scene : PackedScene

var _dialogue_system : DialogueSystem
var _command_handler : CommandHandler
var _is_typing_option : bool = false

func _ready():
	keep_editing_on_text_submit = true
	_dialogue_system = GameManager.get_dialogue_system()
	_command_handler = GameManager.get_command_handler()
	_dialogue_system.dialogue_started.connect(_handle_option)
	_dialogue_system.dialogue_next_object.connect(_handle_option)
	_dialogue_system.dialogue_ended.connect(_on_dialogue_ended)

	text_submitted.connect(_on_text_submitted)
	text_changed.connect(_on_text_changed)
	enter_button.pressed.connect(_on_text_submitted)
	grab_focus()

func _on_text_submitted(_str : String):
	if _is_typing_option && text != placeholder_text:
		return
	_clear_autocomplete_hints()
	player_enter.emit(_str)
	text = ""

func _on_dialogue_ended():
	_is_typing_option = false
	placeholder_text = ""

## Changes the typed text to the option text if typing option, else shows autocomplete
func _on_text_changed(new_text : String):
	if _is_typing_option:
		var option : String = _dialogue_system.current_object.options[0]
		option = option.substr(0, len(new_text))
		text = option
		caret_column = len(text)
		return

	# Here find a way to query the command handler for available commands starting with player input
	_clear_autocomplete_hints()

	var possible_commands : Array[String] = _command_handler.commands_start_with(new_text)
	for cmd in possible_commands:
		var autocomplete_item : AutocompleteItem = autocomplete_item_scene.instantiate()
		autocomplete_item.set_text(cmd)
		autocomplete_container.add_child(autocomplete_item)
	pass

func _clear_autocomplete_hints():
	for c in autocomplete_container.get_children():
		c.queue_free()

func _handle_option():
	if !_dialogue_system.current_object.options == null:
		placeholder_text = _dialogue_system.current_object.options[0]
		_is_typing_option = true
	else:
		_is_typing_option = false
	pass
	
