class_name ContextMenuControlItem extends PanelContainer

@export var highlight : HighlightOnHover
@export var container : Control

var _default_stylebox : StyleBoxFlat

signal on_pressed

## Sets up the node, the control will be spawned as a child of this item
func setup(control : Control, takes_input : bool = true):
	container.add_child(control)

	_default_stylebox = get_theme_stylebox("panel")

	set_process_input(takes_input)

func _input(event):
	if event is InputEventMouseButton:
		if !event.button_index == MOUSE_BUTTON_LEFT:
			return
		if !event.pressed:
			return
		if highlight.is_mouse_in:
			on_pressed.emit()
			
func is_mouse_in() -> bool:
	return highlight.is_mouse_in
