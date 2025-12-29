class_name Entity extends Resource

@export var base_health: float
@export var base_attack_damage: float
@export var display_name: String
@export var texture : ImageTexture
@export var description: String
@export var loot_table: Array
@export var base_sp: int

## The current health of the entity
@export var current_health: float
@export var current_sp: int
@export var can_escape: bool

signal on_take_hit_from_weapon(weapon_id: String)
signal on_take_damage(damage : float)

## Is this entity considered dead
var is_dead : bool = false

## The room in which this entity is currently, if the entity has not been spawned this returns null
var _current_room : Room

static func fromJSON(json: String) -> Entity:
	var parsed_json = JSON.parse_string(json)
	if parsed_json == null:
		return null
	parsed_json = parsed_json as Dictionary

	## Check if entity specified a custom type
	var type = parsed_json.get("type")
	var image_path = parsed_json.get("image_path")

	var entity: Entity

	if type != null:
		var _path: String = "res://scripts/features/entities/types/%s.gd" % type
		if !FileAccess.file_exists(_path):
			GlobalLogger.log_e(
				"Failed to create entity, the specifid file does not exist: " + _path
			)
			return null
		else:
			entity = load(_path).new()
	else:
		entity = Entity.new()

	## Sets the texture of that entity
	if image_path != null:
		var path : String = "res://resources/images/entities/%s.png" % image_path
		entity.texture = ImageTexture.create_from_image(load(path))
	else:
		entity.texture = ImageTexture.new()

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
				GlobalLogger.log_w("ParsingEntity> %s has no property called %s!" % [type, key])

	return entity


#--------------------------------------------------------------------#
#                        General Interactions                        #
#--------------------------------------------------------------------#


func interact():
	if GameManager._player_manager.current_state != GlobalEnums.PlayerState.WANDERING:
		GameManager.get_ui().new_log(GlobalEnums.busy_error_log)
		return
	_interact()
	pass


## What happens when the player interacts with this entity. To be overriden
## By default, adds a "No interaction possible" log
func _interact():
	if !is_dead:
		GameManager.get_ui().new_log(Log.new("This entity does not want to interact with you."))
		return
	GameManager.get_ui().new_log(Log.new("It's just a corpse..."))
	pass



## What happens when the player attempts to talk to the entity.
func talk():
	if GameManager._player_manager.current_state != GlobalEnums.PlayerState.WANDERING:
		GameManager.get_ui().new_log(GlobalEnums.busy_error_log)
		return
	_talk()
	pass


## What happens when the player attempts to talk to the entity. To be overriden
## By default does nothing
func _talk():
	pass

## The name to be displayed of this entity, this can change based on the entity's status,
## if you want the default name, consider using the `display_name` variable directly
func get_display_name() -> String:
	return _get_display_name()

## The name to be displayed of this entity, to be overriden, by default returns the `display_name` or "Dead + `display_name`"
func _get_display_name() -> String:
	if is_dead:
		return "dead %s" % display_name
	return display_name

## The description to be displayed of this entity, this can change based on the entity's status,
## if you want the default description, consider using the `description` variable directly
func get_description() -> String:
	return _get_description()

## The description to be displayed of this entity, to be overriden
func _get_description() -> String:
	if is_dead:
		return "just it's corpse"
	return description

#--------------------------------------------------------------------#
#                         Attack and Combat                          #
#--------------------------------------------------------------------#

func on_attacked():
	if GameManager._player_manager.current_state != GlobalEnums.PlayerState.WANDERING:
		GameManager.get_ui().new_log(GlobalEnums.busy_error_log)
		return
	_on_attacked()
	pass


## What happens when the player chooses the attack command on this entity. To be overriden
## By default, starts combat with entity
func _on_attacked():
	if is_dead:
		GameManager.get_ui().new_log(Log.new("You brandish your sword with courage staring down at this %s, but it's very clearly dead already." % display_name))
		return
	GameManager.get_combat_manager().start_fight(self)
	pass


## Entity takes a hit from weapon_id
func take_hit(weapon_id: String):
	var registry: Registry = GameManager.get_registry()
	var weapon_ref: Object = registry.get_entry_by_id(weapon_id)
	if not weapon_ref is Weapon:
		GlobalLogger.log_e(
			"%s> Got attacked with %s, which is not a weapon" % [self.display_name, weapon_id]
		)
		return
	_take_hit(weapon_ref)
	on_take_hit_from_weapon.emit(weapon_id)
	pass


## Entity takes a hit by `_weapon`. To be overriden
## By default, health -= weapon.damage
func _take_hit(_weapon: Weapon):
	take_raw_damage(_weapon.damage)


## Entity takes raw damage
func take_raw_damage(damage: float):
	_take_raw_damage(damage)
	pass


## Entity takes raw damage
## By default, health -= damage, and calls the on_take_damage signal
func _take_raw_damage(damage: float):
	self.current_health -= damage
	on_take_damage.emit(damage)


## When the entity is spawned in a room
func on_spawn():
	_on_spawn()
	pass


## Returns the current weapon of the entity, returns null if none
func get_weapon() -> Weapon:
	return _get_weapon()


## Returns the current weapon of the entity, returns null if none, to be overriden
func _get_weapon() -> Weapon:
	return null


## When the entity is spawned in a room. To be overriden
## By default does nothing
func _on_spawn():
	pass


## Mark this entity as dead, marks the room it's in as changed
func die():
	is_dead = true
	if _current_room != null:
		_current_room.mark_room_as_changed()
	_die()

## What happens when this entity is marked as dead. To be overriden
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
func _generate_fight_sequence(_fight : Fight):
	var moves : Array[CombatMove] = [] 
	return moves
