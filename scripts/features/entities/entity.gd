class_name Entity extends Resource

@export var base_health: float
@export var base_attack_damage: float
@export var display_name: String
@export var description: String
@export var loot_table: Array
@export var base_sp : int
## The current health of the entity
@export var current_health: float
@export var current_sp : int
@export var can_escape: bool

signal on_take_hit(weapon_id : String)


static func fromJSON(json: String) -> Entity:
	var parsed_json = JSON.parse_string(json)
	if parsed_json == null:
		return null
	parsed_json = parsed_json as Dictionary

	## Check if entity specified a custom type
	var type = parsed_json.get("type")

	var entity: Entity

	if type != null:
		var _path: String = "res://scripts/features/entities/types/%s.gd" % type
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
	entity.base_sp = parsed_json.get("base_sp", 3)

	entity.current_health = entity.base_health
	entity.current_sp = entity.base_sp

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
## By default, adds a "No interaction possible" log
func _interact():
	GameManager.get_ui().new_log(Log.new("", "This entity does not want to interact with you."))
	pass


func on_attacked():
	_on_attacked()
	pass


## What happens when the player chooses the attack command on this entity. To be overriden
## By default, starts combat with entity
func _on_attacked():
	GameManager.get_combat_manager().start_fight(self)
	pass


## Entity takes a hit with weapon_id
func take_hit(weapon_id: String):
	var registry: Registry = GameManager.get_registry()
	var weapon_ref: Object = registry.get_entry_by_id(weapon_id)
	if not weapon_ref is Weapon:
		Logger.log_e(
			"%s> Got attacked with %s, which is not a weapon" % [self.display_name, weapon_id]
		)
		return
	_take_hit(weapon_ref)
	on_take_hit.emit(weapon_id)
	pass


## Entity takes a hit by `_weapon`. To be overriden
## By default, health -= weapon.damage
func _take_hit(_weapon: Weapon):
	self.current_health -= _weapon.damage


## When the entity is spawned in a room
func on_spawn():
	_on_spawn()
	pass


## When the entity is spawned in a room. To be overriden
## By default does nothing
func _on_spawn():
	pass


## What happens when the player attempts to talk to the entity.
func talk():
	_talk()
	pass


## What happens when the player attempts to talk to the entity. To be overriden
## By default does nothing
func _talk():
	pass


## What happens when the entity's health reaches 0.
func die():
	pass


## What happens when the entity's health reaches 0. To be overriden
## By default does nothing
func _die():
	pass


## Returns the loot of the entity.
## Format: [{"item_id_1" : quantity_1}, {"item_id_2" : quantity_2}]
func get_loot() -> Array:
	return _get_loot()


## Returns the loot of the entity. To be overriden
## By default looks at the loot table and picks items and quantities randomly
func _get_loot() -> Array:
	var item_ids = loot_table.map(func(e): return e["item_id"])
	var item_chances = loot_table.map(func(e): return e["chance"])
	var item_quantities = loot_table.map(
		func(e):
			return Utils.skewed_random_distribution(
				e.get("min_quantity", 1), e.get("max_quantity", 1)
			)
	)
	var picked_item_id: Array = Utils.pick_from_chance(item_ids, item_chances, item_quantities)
	var arr: Array = []
	for i in range(picked_item_id.size()):
		arr.append({"item_id": picked_item_id[i], "quantity": item_quantities[i]})

	return arr


## Generates the fight sequence of this entity in combat
func generate_fight_sequence(fight: Fight) -> Array[CombatMove]:
	return _generate_fight_sequence(fight)


## Generates the fight sequence of this entity in combat, to be overriden
## By default returns an empty array
func _generate_fight_sequence(_fight: Fight) -> Array[CombatMove]:
	return []
