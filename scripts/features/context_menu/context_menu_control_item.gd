class_name ContextMenuControlItem extends PanelContainer

@export var highlight : HighlightOnHover
@export var container : Control

var _default_stylebox : StyleBoxFlat

## Gets emitted when this item is left clicked
signal on_pressed
## Gets emitted whenever an input is recorded while this item is under the mouse
signal on_hover_input(event : InputEvent)

## Sets up the node, the control will be spawned as a child of this item
func setup(control : Control, takes_input : bool = true):
	container.add_child(control)

	_default_stylebox = get_theme_stylebox("panel")

	set_process_input(takes_input)

func _input(event):
	if highlight.is_mouse_in:
		on_hover_input.emit(event)
		if event is InputEventMouseButton:
			if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
				on_pressed.emit()
			
func is_mouse_in() -> bool:
	return highlight.is_mouse_in
