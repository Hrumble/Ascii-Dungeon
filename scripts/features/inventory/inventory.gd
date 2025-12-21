class_name Inventory

var _pre_log : String = "Inventory> "

## Gets called when an item gets added or removed
signal inventory_modified

## Contains a dictionary of [InventoryItem]
var content : Dictionary

func _init():
	content = {}

## Returns all of the items as an array of [InventoryItem]
func get_items() -> Array:
	return content.values()

## Adds an item to the inventory, default is one.
func add_item(item_id : String, item_qantity : int = 1):
	if content.has(item_id):
		var inventory_item = content[item_id] as InventoryItem
		inventory_item.increase_quantity(item_qantity)
	else:
		content[item_id] = InventoryItem.new(item_id, item_qantity)
	GlobalLogger.log_i(_pre_log + "Added %sx %s to inventory" % [item_qantity, item_id])
	inventory_modified.emit()

## Removes `item_quantity` quantity of item_id from inventory
func remove_item_quantity(item_id : String, item_quantity : int = 1):
	if content.has(item_id):
		var inventory_item = content[item_id] as InventoryItem
		inventory_item.decrease_quantity(item_quantity)
		if inventory_item.item_quantity <= 0:
			remove_item(item_id)
	else:
		GlobalLogger.log_e(_pre_log + "%s does not exist inside the inventory" % item_id)

## Entirely removes an item from the player inventory, no matter it's quantity
func remove_item(item_id : String):
	if not content.erase(item_id):
		GlobalLogger.log_e(_pre_log + "Could not remove %s because it does not exist in the inventory" % item_id)
	else:
		inventory_modified.emit()

## Checks if the inventory contains at least `item_quantity` of `item_id`
func contains_min(item_id : String, item_quantity : int = 1) -> bool:
	if not content.has(item_id):
		return false
	
	var inventory_item : InventoryItem = content[item_id]

	if inventory_item.item_quantity >= item_quantity:
		return true
	else:
		return false

## Returns a reference to the item in registry, or null if there is none in inventory
func get_item(item_id : String):
	if not content.has(item_id):
		return false
	else:
		var inventory_item : InventoryItem = content[item_id]
		return inventory_item.get_item_reference()
	


