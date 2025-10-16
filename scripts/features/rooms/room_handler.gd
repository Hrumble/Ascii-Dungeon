class_name RoomHandler extends Node

signal room_handler_ready
const _pre_log : String = "RoomHandler> "
var _player : MainPlayer

var _room_datasource : RoomDatasource
## Cache of all the generated rooms with their mapped to their coordinates, e.g. [1, 0] -> Room<#4108928340>
var generated_rooms : Dictionary = {}

func initialize():
	_room_datasource = GameManager.get_room_datasource()
	_player = GameManager.get_player_manager().player
	_player.entered_new_room.connect(_on_room_entered)
	await get_tree().process_frame
	room_handler_ready.emit()

## Generates the room at position `pos`
func generate_room_at(pos : Vector2i) -> Vector2i:
	var room : Room = Room.new()
	## Generates the room tone, this is totally random and depends on nothing
	for property_id in RoomProperties.TONE_ID.values():
		var random_value : String = _room_datasource.get_random_value_id(_room_datasource.room_tones, property_id)
		room.set_property(RoomProperties.CATEGORY.TONE, property_id, random_value) 

	## Generates attributes
	## The order in which the attributes are generated matters, population depends on tone, entities depend on population and tone, and so on...
	var room_population = _generate_room_attribute(_room_datasource.room_info, RoomProperties.INFO_ID.POPULATION, room)
	if room_population != null:
		room.set_property(RoomProperties.CATEGORY.INFO, RoomProperties.INFO_ID.POPULATION, room_population)
	
	var room_entities = _generate_room_attribute(_room_datasource.room_entities, RoomProperties.ENTITIES_ID.ENTITIES, room, false)
	if room_entities != null:
		room.room_entities = room_entities
		# room.set_property(RoomProperties.CATEGORY.ENTITIES, RoomProperties.ENTITIES_ID.ENTITIES, room_entities)

	
	## Appends the room to the cache
	generated_rooms[pos] = room
	Logger.log_d(_pre_log + "Room generated : " + str(room))
	return pos

## Returns a room if it exists, else generates the room.
func _get_or_generate_room(pos : Vector2i):
	var room : Room = generated_rooms.get(pos)
	if room == null:
		generate_room_at(pos)
		room = generated_rooms.get(pos)
	return pos

## Runs the logic when the player enters a room
func _on_room_entered(room_pos : Vector2i):
	var room : Room = get_room(room_pos)
	if room == null:
		Logger.log_e(_pre_log + "Could not generate paths for room %s because it does not exist" % _player.current_room)
		return
	## Assigns paths based on chance
	if Utils.roll_chance(.85):
		room.room_front = _get_or_generate_room(room_pos + Vector2i(0, 1))
	if Utils.roll_chance(.70):
		room.room_left = _get_or_generate_room(room_pos + Vector2i(-1, 0))	
	if Utils.roll_chance(.83):
		room.room_right = _get_or_generate_room(room_pos + Vector2i(1, 0))
	if Utils.roll_chance(.96):
		room.room_back = _get_or_generate_room(room_pos + Vector2i(0, -1))
	
	## Instantiate the entities in the room only when player enters, otherwise just keep ids of entities in room
	room.instantiate_entities()

## Returns a reference of the room with uid `room_uid`, null if it doesn't exist
func get_room(room_pos : Vector2i) -> Room:
	var room : Room = generated_rooms.get(room_pos, null)
	if room == null:
		Logger.log_e(_pre_log + "The room with uid %s does not exist" % room_pos)
		return null
	return room

## Returns the position of the rooms at PATH, if no path is there, returns null
func room_get_path(room_pos : Vector2i, path_id : GlobalEnums.PATH_ID):
	var room : Room = get_room(room_pos)
	if room == null:
		Logger.log_e(_pre_log + "Trying to get the path of a non-existant room, %s" % room_pos)
		return null
	match path_id:
		GlobalEnums.PATH_ID.LEFT:
			return room.room_left
		GlobalEnums.PATH_ID.RIGHT:
			return room.room_right
		GlobalEnums.PATH_ID.FRONT:
			return room.room_front
		GlobalEnums.PATH_ID.BACK:
			return room.room_back
	pass

## Returns the room description
func get_room_description(room_pos : Vector2i) -> String:
	var room : Room = get_room(room_pos)
	if room == null:
		return "NO_ROOM_WITH_UID"
	else:
		return room.get_room_description()

## Generates the ID for a specific room attribute, and returns it, if no suitable matches have been found, returns null.
## `category` is the dictionnary containing that attribute inside the `RoomDatasource` e.g. (`_room_datasource.room_info`). 
## `attribute_id` is the specific attribute ID e.g. (`population`). 
## `room` is the room...
## `weight_contest` to be toggled if you want to weight contest the properties, this means that only one will be chosen, otherwise, it returns an array of all possibilites
## ** If weight_contest is set to false, this returns an array and not a String!**
func _generate_room_attribute(category : Dictionary, attribute_id : String, room : Room, weight_contest : bool = true):
	var properties = _room_datasource.get_properties_id(category, attribute_id)
	if properties == null:
		Logger.log_e(_pre_log + "Error occured when trying to get properties of %s" % attribute_id)
		return
	var eligible_properties_id : Array = []
	for property_id in properties.keys():
		if _property_conditions_met(category, attribute_id, property_id, room):
			eligible_properties_id.append(property_id)
	Logger.log_d(_pre_log + "Room eligible %s : %s" % [attribute_id, str(eligible_properties_id)])
	var picked_property = _pick_property(category, attribute_id, eligible_properties_id, weight_contest)
	if picked_property == null:
		Logger.log_d(_pre_log + "No suitable %s found for room" % attribute_id)
		return null
	else:
		return picked_property

## Picks a single property from an array of eligible ones based on chance and weight. 
## the properties MUST have a "chance" and "weight" key on the first nesting layer.
func _pick_property(category_dic : Dictionary, attribute_id : String, property_ids : Array, weight_contest : bool = true):
	var chances : Array = []
	for property_id in property_ids:
		var chance = _room_datasource.get_property_value(category_dic, attribute_id, property_id, "chance")
		if chance != null:
			chances.append(chance)
	var eligible_ids : Array = Utils.pick_from_chance(property_ids, chances)
	## If weight_contest is set to false, return the chance winners
	if !weight_contest:
		if eligible_ids.size() == 0:
			return null
		else:
			return eligible_ids
	var weights : Array = []
	for property_id in eligible_ids:
		var weight = _room_datasource.get_property_value(category_dic, attribute_id, property_id, "weight")
		if weight != null:
			weights.append(weight)

	return Utils.pick_from_weight(eligible_ids, weights)

## Verifies if the `conditions` and `counter_conditions` keys of `property_id` are met by the room
func _property_conditions_met(category_dic: Dictionary, attribute_id: String, property_id: String, room: Room) -> bool:
	var conditions = _room_datasource.get_property_value(category_dic, attribute_id, property_id, "conditions")
	var counter_conditions = _room_datasource.get_property_value(category_dic, attribute_id, property_id, "counter_conditions")

	# No conditions at all -> automatically matches
	if conditions == null and counter_conditions == null:
		Logger.log_d(_pre_log + property_id + " has no conditions or counter-conditions, it is a match by default")
		return true

	# Check positive conditions
	if conditions != null:
		for category in conditions.keys():
			for condition_attribute_id in conditions[category].keys():
				var valid_properties: Array = conditions[category][condition_attribute_id]
				var satisfied := false

				for required_property in valid_properties:
					if room.has_property(category, condition_attribute_id, required_property):
						satisfied = true
						break
				
				if not satisfied:
					Logger.log_d(_pre_log + "Room does not meet required conditions for %s in %s:%s" % [
						property_id, category, condition_attribute_id
					])
					return false

	# Check counter conditions (must *not* be present)
	if counter_conditions != null:
		for category in counter_conditions.keys():
			for condition_attribute_id in counter_conditions[category].keys():
				var forbidden_properties: Array = counter_conditions[category][condition_attribute_id]

				for forbidden_property in forbidden_properties:
					if room.has_property(category, condition_attribute_id, forbidden_property):
						Logger.log_d(_pre_log + "Room has %s which is a counter condition. It does not meet the required conditions for %s" % [
							forbidden_property, property_id
						])
						return false

	return true
