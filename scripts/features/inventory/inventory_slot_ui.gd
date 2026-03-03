class_name InventorySlotUI extends ItemSlotUI

@export var count_label : Label

var count : int = 0

## Sets the count label of this item
func set_count(item_count : int):
	count = item_count
	_update_slot()

func _update_slot():
	super._update_slot()
	count_label.text = str(count)
