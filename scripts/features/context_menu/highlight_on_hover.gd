class_name HighlightOnHover extends Node

@export var container : PanelContainer = null

var _default_stylebox : StyleBoxFlat
## Is the mouse currently selecting the specified container
var is_mouse_in : bool = false

func _ready():
	_default_stylebox = container.get_theme_stylebox("panel")

func _process(_delta):
	var mouse_pos : Vector2 = container.get_global_mouse_position()
	var _container_size : Rect2 = container.get_global_rect()

	if _container_size.has_point(mouse_pos) && !is_mouse_in:
		_on_mouse_enter()

	elif !_container_size.has_point(mouse_pos) && is_mouse_in:
		_on_mouse_exit()


func _on_mouse_enter():
	is_mouse_in = true

	var stylebox : StyleBoxFlat = _default_stylebox.duplicate()
	stylebox.bg_color = _default_stylebox.bg_color + Color(.2, .2, .2)

	container.add_theme_stylebox_override("panel", stylebox)

func _on_mouse_exit():
	is_mouse_in = false

	container.add_theme_stylebox_override("panel", _default_stylebox)
