class_name Entity

var base_health : float
var base_attack_damage : float
var display_name : String

func _init():
	pass

static func fromJSON(json : String) -> Entity:
	var parsed_json = JSON.parse_string(json)
	if parsed_json == null:
		return null
	parsed_json = parsed_json as Dictionary
	var entity : Entity = Entity.new()
	entity.base_health = parsed_json.get("base_health", 0.0)
	entity.base_attack_damage = parsed_json.get("base_attack_damage", 0.0)
	entity.display_name = parsed_json.get("display_name", "PARSE_ERROR")
	return entity
