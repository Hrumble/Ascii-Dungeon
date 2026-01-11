class_name InventorySlotUI extends Control

@export var texture_rect : TextureRect
@export var count_label : Label
@export var highlight_on_hover : HighlightOnHover

var item : Item
var count : int = 0

var _registry : Registry

signal on_updated
## When this item is right clicked
signal on_right_click

func _get_registry() -> Registry:
	if _registry == null:
		_registry = GameManager.get_registry()
	return _registry

## Sets the item and the count to be displayed by this slot
func set_item(item_id : String, item_count : int = 1):
	item = _get_registry().get_entry_by_id(item_id)	
	count = item_count
	# Disconnects every previously made connections to right click
	for connection in on_right_click.get_connections():
		on_right_click.disconnect(connection["callable"])

	if item != null:
		_update_slot()

## Removes the item and its count from this slot
func remove_item():
	item = null
	_update_slot()
	pass

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_RIGHT:
			on_right_click.emit()

func set_context_menu(context_menu : ContextMenu):
	item.get_context_menu(context_menu)

## Sets the count label of this item
func set_count(item_count : int):
	count = item_count
	_update_slot()

func _update_slot():
	if item == null:
		texture_rect.texture = null
		count_label.text = ""
		on_updated.emit()
		return

	texture_rect.texture = item.texture
	count_label.text = str(count)
	on_updated.emit()
