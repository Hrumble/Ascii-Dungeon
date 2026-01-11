class_name Item extends Resource

@export var value : float 
@export var display_name : String
@export var texture : Texture2D
@export var description : String

static func fromJSON(json : String) -> Item:
	var parsed_json : Dictionary = JSON.parse_string(json)
	if parsed_json == null:
		return null
	parsed_json = parsed_json as Dictionary

	## Check if item has custom type
	var type = parsed_json.get("type")
	var image_path = parsed_json.get("image_path")
	var item : Item
	if type != null:
		var _path : String = "res://scripts/features/items/types/%s.gd" % type
		if !FileAccess.file_exists(_path):
			GlobalLogger.log_e("Failed to create Item, the specified unique script does not exist: " + _path)
			return null
		else:
			item = load(_path).new()
	else:
		item = Item.new()

	## Sets the texture of that entity
	if image_path != null:
		var path : String = "res://resources/images/items/%s.png" % image_path
		if FileAccess.file_exists(path):
			item.texture = load(path)
			GlobalLogger.log_i("Successfully assigned texture to item: %s" % path)
		else:
			GlobalLogger.log_e("Failed to assign texture to item, texture at %s does not exist." % path)
			item.texture = ImageTexture.new()
	else:
		item.texture = ImageTexture.new()

	item.display_name = parsed_json.get("display_name", "PARSE_ERR")
	item.description = parsed_json.get("description", "Nothing to say about this...")
	item.value = parsed_json.get("value", 0.0)

	if type != null:
		var type_properties = parsed_json.get("type_properties", {}) 
		for key in type_properties.keys():
			if key in item:
				item.set(key, type_properties[key])
			else:
				GlobalLogger.log_w("ParsingItem> %s has no property called %s!" % [type, key])

	return item

## What happens when the player uses the item
func use():
	_use()
	pass

## What happens when the player uses the item. To be overriden
func _use():
	pass

## What happens when the player gets this item in their inventory
func on_aquired():
	_on_aquired()
	pass

## What happens when the player gets this item in their inventory. To be overriden
func _on_aquired():
	pass
