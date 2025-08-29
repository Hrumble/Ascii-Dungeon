class_name Item

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
	var item : Item = Item.new()
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

