class_name Room


## Handles which rooms are around it, if null, there is no passage to a room by here
var room_front = null
var room_back = null
var room_left = null
var room_right = null

enum PATH_ID {
	FRONT,
	BACK,
	LEFT,
	RIGHT
}

const _pre_log : String = "Room> "

var _room_datasource : RoomDatasource
var _registry : Registry

var room_entities : Array

## An array containing the actual instantiated entities of the room, the order is the same as the `room_entities` array.
var instantiated_entities : Array
## A bool that keeps track on wether or not the entities have been spawned yet
var has_entities_spawned : bool = false

var _description = null

var room_properties : Dictionary = {

}

static func fromJSON(json : String) -> Room:
	var parsed_json : Dictionary = JSON.parse_string(json)
	if parsed_json == null:
		Logger.log_e(_pre_log + "Failed to parse json")
		return null
	return null

func _init():
	_room_datasource = GameManager.get_room_datasource()
	_registry = GameManager.get_registry()

## Sets a particular property of a room
func set_property(category : String, attribute_id : String, property_id : String):
	if !room_properties.has(category):
		room_properties[category] = {}
	room_properties[category][attribute_id] = property_id

## Instantiates the entities of the room, if they have not been yet
func instantiate_entities():
	if room_entities.size() != instantiated_entities.size():
		for room_entity in room_entities:
			var spawned_entity : Entity = _registry.get_entry_copy(room_entity)
			spawned_entity.on_spawn()
			instantiated_entities.append(spawned_entity)
	Logger.log_d(_pre_log + "Instantiated entities: %s" % str(instantiated_entities))
	has_entities_spawned = true

## Creates the description of the room and caches it as to not create it every time
func get_room_description() -> String:
	if !_description == null:
		return _description
	var full_description : String = ""
	full_description += "The room is " 	
	# Tone description
	var room_tone : Dictionary = room_properties.get(RoomProperties.CATEGORY.TONE)
	var new_line_tracker : int = 1
	for attribute_id in room_tone.keys():
		if new_line_tracker % 2 == 0:
			full_description += "\n"
		full_description += "%s " % _room_datasource.get_property_value(
				_room_datasource.room_tones,
				attribute_id,
				room_tone.get(attribute_id)
		)
		new_line_tracker += 1
	var room_info : Dictionary = room_properties.get(RoomProperties.CATEGORY.INFO, {})
	full_description += "\n"
	for attribute_id in room_info.keys():
		full_description += "%s " % _room_datasource.get_property_value(
			_room_datasource.room_info,
			attribute_id,
			room_info.get(attribute_id)
		)
	full_description = _generate_paths_description(full_description)
	full_description = _generate_entity_description(full_description)
	_description = full_description
	return _description

## Checks if a room has a particular `property` inside the `attribute` of `category`
## e.g. \n
##```
## room.has_property(RoomProperties.CATEGORY.INFO, RoomProperties.INFO_ID.POPULATION, "single") -> gives false
## ```
func has_property(category : String, attribute : String, property : String) -> bool:
	var _category = room_properties.get(category)
	if _category == null:
		return false
	var _attribute = _category.get(attribute)
	if _attribute == null:
		return false

	return _attribute == property

func has_entity(entity_id : String) -> bool:
	return entity_id in room_entities

## Generates the description for the paths.
func _generate_paths_description(full_description : String):
	# create two new lines
	full_description += "\n\n[b][color=yellow]"
	if room_front != null:
		full_description += "There's a path in front of you. "
	if room_left != null:
		full_description += "There's a path to your left. "
	if room_right != null:
		full_description += "There's a path to your right. "
	if room_back != null:
		full_description += "There's a path behind you."
	full_description += "[/color][/b]"
	return full_description

func _generate_entity_description(full_description : String):
	full_description += "\n"
	for entity_id in room_entities:
		var entity : Entity = _registry.get_entry_by_id(entity_id)
		full_description += "There's a %s, %s. " % [entity.display_name, entity.description]
	return full_description
		
func _to_string():
	return str(room_properties)
