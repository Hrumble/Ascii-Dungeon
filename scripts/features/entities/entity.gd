class_name Entity

var base_health : float
var base_attack_damage : float
var display_name : String
var description : String

## Can you talk to the creature (if not it vans(vans, converse))
var can_converse : bool

var can_escape : bool

## Does the creature sell anything, only valid if can_converse = true
var is_merchant : bool

func _init():
	pass

static func fromJSON(json : String) -> Entity:
	var parsed_json = JSON.parse_string(json)
	if parsed_json == null:
		return null
	parsed_json = parsed_json as Dictionary
	var entity : Entity = Entity.new()
	entity.base_health = parsed_json.get("base_health", 5.0)
	entity.base_attack_damage = parsed_json.get("base_attack_damage", 0.0)
	entity.display_name = parsed_json.get("display_name", "NO_DISPLAY_NAME_PROVIDED")
	entity.description = parsed_json.get("description", "nothing to say about that...")
	entity.is_merchant = parsed_json.get("is_merchant", false)
	entity.can_escape = parsed_json.get("can_escape", true)
	return entity

