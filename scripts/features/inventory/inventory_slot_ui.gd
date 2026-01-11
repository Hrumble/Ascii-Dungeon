class_name InventorySlotUI extends Control

@export var texture_rect : TextureRect
@export var count_label : Label

var item : Item
var count : int = 0

var _registry : Registry

signal on_updated

func _ready():
	_registry = GameManager.get_registry()
	_update_slot()

## Sets the item and the count to be displayed by this slot
func set_item(item_id : String, item_count : int = 1):
	item = _registry.get_entry_by_id(item_id)	
	count = item_count
	if item != null:
		_update_slot()

## Removes the item and its count from this slot
func remove_item():
	item = null
	_update_slot()
	pass

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

