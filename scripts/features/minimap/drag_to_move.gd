extends Node

@export var camera : Camera2D

const MIN_ZOOM : Vector2 = Vector2(1, 1)
const MAX_ZOOM : Vector2 = Vector2(3, 3)
const ZOOM_MODIF : Vector2 = Vector2(.1, .1)
const DRAG_ZOOM_MODIF : float = .1

var is_dragging : bool = false

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			is_dragging = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom = clamp(camera.zoom + ZOOM_MODIF, MIN_ZOOM, MAX_ZOOM)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom = clamp(camera.zoom - ZOOM_MODIF, MIN_ZOOM, MAX_ZOOM)

	if event is InputEventMouseMotion && is_dragging:
		move(event.relative)

func move(mouse_offset : Vector2):
	camera.position -= mouse_offset/camera.zoom
