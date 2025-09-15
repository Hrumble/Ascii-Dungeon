class_name Item extends Resource

var value : float 
var display_name : String
var description : String
## Can you wear the item like armour
var wearable : bool
## can you equip the item like a sword NOT the same as wearable
var equipable : bool
var base_damage : float

var consumable : bool
var amount_healed : float


## Need to be implemented
var status_effect
var status_effect_time

## On what slot does the item go (if wearable = true)
var equipment_slot

static func fromJSON(json : String) -> Item:
	var parsed_json : Dictionary = JSON.parse_string(json)
	if parsed_json == null:
		return null
	parsed_json = parsed_json as Dictionary

	## Check if item has custom type
	var unique_script_name = parsed_json.get("type")
	var item : Item
	if unique_script_name != null:
		var _path : String = "res://script/features/items/types/%s.gd" % unique_script_name
		if !FileAccess.file_exists(_path):
			Logger.log_e("Failed to create Item, the specified unique script does not exist: " + _path)
			return null
		else:
			item = load(_path).new()
	else:
		item = Item.new()

	item.display_name = parsed_json.get("display_name", "PARSE_ERR")
	item.description = parsed_json.get("description", "Nothing to say about this...")
	item.value = parsed_json.get("value", 0.0)

	## equipment
	item.wearable = parsed_json.get("wearable", false)
	
	## equipables (sword, shield wtv)
	item.equipable = parsed_json.get("equipable", false)
	item.base_damage = parsed_json.get("base_damage", 0.0)

	## Consumables
	item.consumable = parsed_json.get("consumable", false)
	return item

## What happens when the player uses the item
func use():
	_use()
	pass

## What happens when the player uses the item. To be overriden
func _use():
	pass

## What happens when the player equips the item
func on_equip():
	_on_equip()
	pass

## What happens when the player equips the item. To be overriden
func _on_equip():
	pass

## What happens when the player gets this item in their inventory
func on_aquired():
	_on_aquired()
	pass

## What happens when the player gets this item in their inventory. To be overriden
func _on_aquired():
	pass
