class_name PickerOption extends PanelContainer

@export var _label : Label
@export var _detail_label : Label

var value = null

## Sets the option's text, the `detail` if not null must be a string. The `value` can be used to store anything
func set_text(text : String, _detail = null, _value = null):
	_label.text = text
	if _detail != null:
		_detail_label.text = _detail
		_detail_label.show()
	else:
		_detail_label.hide()
	value = _value

## Sets the visual style of the option to selected
func select():
	theme_type_variation = "OptionPickedPanel"

## Sets the visual style of the option to not selected
func unselect():
	theme_type_variation = "OptionNotSelectedPanel"
	
