class_name TelescopeUI extends Control

@export var _search_bar : LineEdit
@export var _options_container : Control
@export var _info_container : Control

var _all_options : Array[TelescopeOption]
var _shown_options : Array[TelescopeOption]
var _selected_option : int = 0
var _is_searching : bool = false

signal on_close(value)

func _ready():
	_search_bar.text_changed.connect(_on_search)
	_search_bar.text_submitted.connect(func(_t): grab_focus())
	_close(true)

func open(options : Array[TelescopeOption]):
	_search_bar.text = ""
	_all_options = options.duplicate(true)
	_clear_children()
	_populate()
	show()
	await get_tree().process_frame
	grab_focus()

func _close(cancel : bool = false):
	if cancel || _shown_options.size() <= 0:
		on_close.emit(null)
	else:
		on_close.emit(_shown_options[_selected_option].value)
	hide()
	pass

func _gui_input(event):
	if event.is_action_pressed("ui_previous"):
		_select_option(_selected_option - 1)
	elif event.is_action_pressed("ui_next"):
		_select_option(_selected_option + 1)
	elif event.is_action_pressed("ui_end"):
		_close(true)
	elif event.is_action_pressed("ui_search"):
		_is_searching = true
		await get_tree().process_frame
		_search_bar.grab_focus()
	elif event.is_action_pressed("ui_confirm"):
		_close()

func _select_option(n : int):
	if (_shown_options.size() <= 0):
		return
	_shown_options[_selected_option].deselect()
	_selected_option = n % _shown_options.size()
	_shown_options[_selected_option].select()
	_info_container.remove_child(_info_container.get_child(0))
	_info_container.add_child(_shown_options[_selected_option].info)

func _clear_children():
	for c in _options_container.get_children():
		c.queue_free()
		_shown_options.clear()

func _hide_children():
	for c : Control in _options_container.get_children():
		c.hide()
	for c : Control in _info_container.get_children():
		c.hide()

func _populate():
	_shown_options.clear()
	_selected_option = 0
	_hide_children()
	for option in _all_options:
		_shown_options.append(option)
		_options_container.add_child(option)

func _on_search(search_term : String):
	_shown_options.clear()
	_hide_children()
	if search_term.is_empty():
		for option in _all_options:
			_shown_options.append(option)
			option.show()
		return
	for option in _all_options:
		if search_term.to_lower() in option.option_name.to_lower():
			_shown_options.append(option)
			option.show()


			
	
