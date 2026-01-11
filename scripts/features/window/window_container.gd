class_name WindowContainer extends Control


@export_subgroup("Window Options")
## The content this window holds
@export var content_scene : PackedScene
## Wether or not a close button is available
@export var can_close : bool
## Title of the window
@export var window_title : String = "My Window"

@export_subgroup("Do Not Change")
@export var title_label : Label
@export var window_header : Control
@export var close_button : Button
@export var content_container : Control

var _mouse_in : bool = false
var _dragging : bool = false
var _handle

var content : Control

func _ready():
	# Spawns the content as a child of this window
	title_label.text = window_title
	content = content_scene.instantiate()
	content_container.add_child(content)

	content.visibility_changed.connect(_on_content_vis_changed)

	window_header.mouse_entered.connect(_on_mouse_enter_header)
	window_header.mouse_exited.connect(_on_mouse_exit_header)

	close_button.pressed.connect(close)

	if !can_close:
		close_button.hide()
	else:
		close_button.show()

## If the content hides or shows than so should the window
func _on_content_vis_changed():
	visible = content.visible

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

func _process(_delta):
	if !_dragging:
		return
	position = get_viewport().get_mouse_position() + _handle


func _on_mouse_enter_header():
	_mouse_in = true

func _on_mouse_exit_header():
	_mouse_in = false

## Calls open on its children if it exists
func open(args : Array = []):
	if content.has_method("open"):
		content.callv("open", args)

## Calls close on its children if it exists
func close():
	if content.has_method("close"):
		content.close()

## Toggles the window open or close
func toggle():
	if visible:
		close()
	else:
		open()
