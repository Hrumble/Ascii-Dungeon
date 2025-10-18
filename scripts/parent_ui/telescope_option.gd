## An option for the telescope picker, stores the displayed name of the option as well as the returned value when selected
class_name TelescopeOption extends PanelContainer

## The display name of the option
var option_name : String
# dynamic, the value held by the option
var value
var info : Control

var _name_label : Label

## Sets up the telescope option
func setup_option(_name : String):
	option_name = _name
	_name_label = Label.new()
	_name_label.text = option_name
	add_child(_name_label)

func select():
	theme_type_variation = "OptionPickedPanel"

func deselect():
	theme_type_variation = "OptionNotSelectedPanel"
