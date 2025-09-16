class_name Entity extends Resource

@export var base_health : float
@export var base_attack_damage : float
@export var display_name : String
@export var description : String
@export var loot_table : Array

@export var can_escape : bool

func _init():
	pass

static func fromJSON(json : String) -> Entity:
	var parsed_json = JSON.parse_string(json)
	if parsed_json == null:
		return null
	parsed_json = parsed_json as Dictionary

	## Check if entity specified a custom type
	var type = parsed_json.get("type")

	var entity : Entity

	if type != null:
		var _path : String = "res://scripts/features/entities/types/%s.gd" % type
		if !FileAccess.file_exists(_path):
			Logger.log_e("Failed to create entity, the specifid file does not exist: " + _path)
			return null
		else:
			entity = load(_path).new()
	else:
		entity = Entity.new()

	entity.base_health = parsed_json.get("base_health", 5.0)
	entity.base_attack_damage = parsed_json.get("base_attack_damage", 0.0)
	entity.display_name = parsed_json.get("display_name", "NO_DISPLAY_NAME_PROVIDED")
	entity.description = parsed_json.get("description", "nothing to say about that...")
	entity.can_escape = parsed_json.get("can_escape", true)
	entity.loot_table = parsed_json.get("loot_table", [])

	if type != null:
		var type_properties = parsed_json.get("type_properties", {}) 
		for key in type_properties.keys():
			if key in entity:
				entity.set(key, type_properties[key])
			else:
				Logger.log_w("ParsingEntity> %s has no property called %s!" % [type, key])

	return entity

func interact():
	_interact()
	pass

## What happens when the player interacts with this entity. To be overriden
func _interact():
	print(self._get_loot())
	pass

func on_attacked(weapon_id : String):
	_on_attacked(weapon_id)
	pass

## What happens when the player attacks this entity, the weapon is the weapon with which the player attacks. To be overriden
func _on_attacked(_weapon_id : String):
	pass

func talk():
	_talk()
	pass

## What happens when the player attempts to talk to the entity. To be overriden
func _talk():
	pass

## What happens when the entity's health reaches 0.
func die():
	pass

## What happens when the entity's health reaches 0. To be overriden
func _die():
	pass

## Returns the loot of the mob
func get_loot():
	_get_loot()
	pass

## Returns the loot of the mob. To be overriden
func _get_loot() -> Array:
	var item_ids = loot_table.map(func(e): return e["item_id"])
	var item_chances = loot_table.map(func(e): return e["chance"])
	var item_quantities = loot_table.map(func(e): 
		return Utils.skewed_random_distribution(e.get("min_quantity", 1), e.get("max_quantity", 1))
	)
	var picked_item_id : Array = Utils.pick_from_chance(item_ids, item_chances, item_quantities)
	var arr : Array = []
	for i in range(picked_item_id.size()):
		arr.append({"item_id": picked_item_id[i], "quantity": item_quantities[i]})

	return arr

