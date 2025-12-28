class_name ContextMenuTextItem extends PanelContainer

@export var label : Label
@export var secondary_label : Label

var _default_stylebox : StyleBoxFlat

var _is_mouse_in : bool = false

signal on_pressed

## Sets up the node, the secondary text is a lighter text placed at the far right of the node, e.g. for keymaps
func setup(text : String, secondary_text : String = ""):
	label.text = text
	secondary_label.text = secondary_text

	_default_stylebox = get_theme_stylebox("panel")

	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)

func _on_mouse_enter():
	_is_mouse_in = true

	var stylebox : StyleBoxFlat = _default_stylebox.duplicate()
	stylebox.bg_color = _default_stylebox.bg_color + Color(.2, .2, .2)

	add_theme_stylebox_override("panel", stylebox)

func _on_mouse_exit():
	_is_mouse_in = false

	add_theme_stylebox_override("panel", _default_stylebox)

func _input(event):
	if event is InputEventMouseButton:
		if !event.button_index == MOUSE_BUTTON_LEFT:
			return
		if !event.pressed:
			return
		if _is_mouse_in:
			on_pressed.emit()
			
