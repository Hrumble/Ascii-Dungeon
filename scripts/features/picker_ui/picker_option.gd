class_name PickerOption extends PanelContainer

@export var _label : Label

func set_text(text : String):
	_label.text = text

## Sets the visual style of the option to selected
func select():
	theme_type_variation = "OptionPickedPanel"

## Sets the visual style of the option to not selected
func unselect():
	theme_type_variation = "OptionNotSelectedPanel"
	
