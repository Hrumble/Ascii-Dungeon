class_name InventoryItem

## Uses the item_id to reference the item inside the registry
var item_id : String
var item_quantity : int

var registry : Registry

func _init(id : String, quantity : int = 1):
	item_id = id
	item_quantity = quantity
	registry = GameManager.get_registry()

## Returns a reference to the item stored in registry
func get_item_reference() -> Object:
	return registry.get_entry_by_id(item_id)

## Increases the quantity
func increase_quantity(inc : int):
	item_quantity += inc

## Decreases the quantity
func decrease_quantity(dec : int):
	item_quantity -= dec
