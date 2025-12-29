extends Control

@export var window_title : String

@export var content_container : Control
@export var title_label : Label
@export var window_header : Control
@export var content_scene : PackedScene

var _mouse_in : bool = false
var _dragging : bool = false
var _handle 

func _ready():
	# Spawns the content as a child of this window
	title_label.text = window_title
	var content = content_scene.instantiate()
	content_container.add_child(content)

	window_header.mouse_entered.connect(_on_mouse_enter_header)
	window_header.mouse_exited.connect(_on_mouse_exit_header)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if _mouse_in and event.pressed:
				if _handle == null:
					_handle = position - get_viewport().get_mouse_position()
				_dragging = true
			elif !event.pressed:
				_dragging = false
				_handle = null

func _process(delta):
	if !_dragging:
		return

	position = get_viewport().get_mouse_position() + _handle


func _on_mouse_enter_header():
	_mouse_in = true

func _on_mouse_exit_header():
	_mouse_in = false
