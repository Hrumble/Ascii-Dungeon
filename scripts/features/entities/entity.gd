class_name Entity extends Resource

@export var base_health : float
@export var base_attack_damage : float
@export var display_name : String
@export var description : String

## Can you talk to the creature (if not it vans(vans, converse))
@export var can_converse : bool

@export var can_escape : bool

## Does the creature sell anything, only valid if can_converse = true
@export var is_merchant : bool

func _init():
	pass

static func fromJSON(json : String) -> Entity:
	var parsed_json = JSON.parse_string(json)
	if parsed_json == null:
		return null
	parsed_json = parsed_json as Dictionary

	## Check if entity specified a unique_script_name
	var unique_script_name = parsed_json.get("unique_script_name")

	var entity : Entity

	if unique_script_name != null:
		var _path : String = "res://scripts/features/entities/unique/%s.gd" % unique_script_name
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
	entity.is_merchant = parsed_json.get("is_merchant", false)
	entity.can_escape = parsed_json.get("can_escape", true)

	return entity

func interact():
	_interact()
	pass

## What happens when the player interacts with this entity. To be overriden
func _interact():
	print("Interacting with: %s" % display_name)
	pass

func attack(weapon_id : String):
	_attack(weapon_id)
	pass

## What happens when the player attacks this entity, the weapon is the weapon with which the player attacks. To be overriden
func _attack(weapon_id : String):
	pass

func talk():
	_talk()
	pass

## What happens when the player attempts to talk to the entity. To be overriden
func _talk():
	pass

func die():
	pass

## What happens when the entity's health reaches 0. To be overriden
func _die():
	pass
