class_name RegistryResultUI extends Control

@export var id_label : Label
@export var texture_rect : TextureRect
@export var display_name_label : Label
@export var description_label : Label
@export var extra_info_container : Control

var _is_info_opened : bool = false
var _is_info_setup : bool = false
var _object : Object

func setup(object : Object):
	extra_info_container.hide()
	_object = object

	id_label.text = _object.get("id")
	display_name_label.text = _object.get("display_name")
	description_label.text = _object.get("description")
	texture_rect.texture = _object.get("texture")

func toggle_extra_info():
	if _is_info_opened:
		extra_info_container.hide()
		_is_info_opened = false
		return

	show_extra_info()
	_is_info_opened = true

func show_extra_info():
	if _is_info_setup:
		extra_info_container.show()
		return

	for property : Dictionary in _object.get_property_list():
		# 4102 seems cryptic but isn't really, its a combination of multiple flags (retarded btw):
		#
		# ``` [https://forum.godotengine.org/t/solved-godot-is-missing-documentation-in-globalscope/116274/4]
		# PropertyUsageFlags can be combined, meaning the 4102 value is a combination of 4096 + 4 + 2, which are respectively:
		# PROPERTY_USAGE_SCRIPT_VARIABLE = 4096
		# PROPERTY_USAGE_EDITOR = 4
		# PROPERTY_USAGE_STORAGE = 2
		# ```
		if property["usage"] != PROPERTY_USAGE_SCRIPT_VARIABLE and property["usage"] != 4102:
			continue
		var rich_label : RichTextLabel = RichTextLabel.new()
		rich_label.bbcode_enabled = true
		rich_label.fit_content = true
		rich_label.add_theme_font_size_override("normal_font_size", 12)
		var val = _object.get(property["name"])
		rich_label.text = "%s : %s -> %s" % [property["name"], type_string(typeof(val)), val]
		extra_info_container.add_child(rich_label)

	_is_info_setup = true
	extra_info_container.show()


func _gui_input(event):
	if (event is InputEventMouseButton):
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			toggle_extra_info()
