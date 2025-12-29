class_name ContextMenuTextItem extends PanelContainer

@export var label : Label
@export var secondary_label : Label
var highlight : HighlightOnHover

var _default_stylebox : StyleBoxFlat

signal on_pressed

func _ready():
	highlight = HighlightOnHover.new()
	highlight.container = self
	add_child(highlight)

## Sets up the node, the secondary text is a lighter text placed at the far right of the node, e.g. for keymaps
func setup(text : String, secondary_text : String = ""):
	label.text = text
	secondary_label.text = secondary_text

	_default_stylebox = get_theme_stylebox("panel")

func _input(event):
	if event is InputEventMouseButton:
		if !event.button_index == MOUSE_BUTTON_LEFT:
			return
		if !event.pressed:
			return
		if highlight.is_mouse_in:
			on_pressed.emit()
			
