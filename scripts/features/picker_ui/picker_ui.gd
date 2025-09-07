class_name PickerUI extends Control

@export var _options_container : Control
@export var _picker_option_scene : PackedScene
@export var _title_container : Label

var _options : Array
var _selected_option : int = -1

## Returns the indice of the picked option in the past array
signal option_picked(option_index : int)

func _ready():
	_close()

func set_up(options : Array, title : String):
	_clear_options()
	for option in options:
		var option_scene : PickerOption = _picker_option_scene.instantiate()
		option_scene.set_text(str(option))
		_options.append(option_scene)
		_options_container.add_child(option_scene)
	_title_container.text = title
	_open()
	pass

func _gui_input(event):
	if event is InputEventKey:
		if !event.pressed:
			return

		if event.keycode == KEY_DOWN:
			_select_option(_selected_option + 1)
		if event.keycode == KEY_UP:
			_select_option(_selected_option - 1)
		elif event.keycode == KEY_ENTER:
			option_picked.emit(_selected_option)
			_close()

func _select_option(index : int):
	# Ensures it stays between 0 and n of options
	if _selected_option != -1:
		_options[_selected_option].unselect()

	_selected_option = index % _options.size()
	_options[_selected_option].select()

func _clear_options():
	for _opt : PickerOption in _options:
		_opt.queue_free()
	_options.clear()
	_selected_option = -1
	pass

func _open():
	show()
	await get_tree().process_frame
	focus_mode = Control.FOCUS_ALL
	grab_focus()

func _close():
	hide()
