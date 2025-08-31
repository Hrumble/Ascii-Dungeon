class_name RoomHandler extends Node

signal room_handler_ready
const _pre_log : String = "RoomHandler> "
var _player : MainPlayer

var _room_datasource : RoomDatasource
## Cache of all the generated rooms with their UID
var generated_rooms : Dictionary = {}
## Used to keep track of the generated rooms, the higher the id, the later it was generated
var _room_uid_tracker : int = 0

func initialize():
	_room_datasource = GameManager.get_room_datasource()
	_player = GameManager.get_player_manager().player
	_player.entered_new_room.connect(_generate_room_paths)
	await get_tree().process_frame
	room_handler_ready.emit()

func generate_random_room() -> int:
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
	
	var room_entities = _generate_room_attribute(_room_datasource.room_entities, RoomProperties.ENTITIES_ID.ENTITIES, room)
	if room_entities != null:
		room.set_property(RoomProperties.CATEGORY.ENTITIES, RoomProperties.ENTITIES_ID.ENTITIES, room_entities)

	
	## Appends the room to the cache
	generated_rooms[_room_uid_tracker] = room
	var _room_uid = _room_uid_tracker
	_room_uid_tracker += 1
	Logger.log_v(_pre_log + "Room generated : " + str(room))

	return _room_uid

## Generates the rooms around the current room if any
func _generate_room_paths():
	var room : Room = get_room(_player.current_room)
	if room == null:
		Logger.log_e(_pre_log + "Could not generate paths for room %s because it does not exist" % _player.current_room)
		return
	## Assigns paths based on chance
	## It is possible for the room to have no path back, in which case the player can not go back
	## This solution has a major problem, it's possible for player to go left, left, left and yet not end up in the same room
	## we're calling this a feature from now **oooohhhh spooky dungeon makes no sense!**
	if Utils.roll_chance(.85):
		room.room_front = generate_random_room()
	if Utils.roll_chance(.70):
		room.room_left = generate_random_room()
	if Utils.roll_chance(.83):
		room.room_right = generate_random_room()
	if Utils.roll_chance(.96):
		if _player.previous_room == -1:
			room.room_back = null
		else:
			room.room_back = _player.previous_room

## Returns a reference of the room with uid `room_uid`, null if it doesn't exist
func get_room(room_uid : int) -> Room:
	var room : Room = generated_rooms.get(room_uid, null)
	if room == null:
		Logger.log_e(_pre_log + "The room with uid %s does not exist" % room_uid)
	return room

## Returns the uid of the rooms at PATH, if no path is there, returns null
func room_get_path(room_uid : int, path_id : Room.PATH_ID):
	var room : Room = get_room(room_uid)
	if room == null:
		Logger.log_e(_pre_log + "Trying to get the path of a non-existant room, %s" % room_uid)
		return null
	match path_id:
		Room.PATH_ID.LEFT:
			return room.room_left
		Room.PATH_ID.RIGHT:
			return room.room_right
		Room.PATH_ID.FRONT:
			return room.room_front
		Room.PATH_ID.BACK:
			return room.room_back
	pass

func get_room_description(room_uid : int) -> String:
	if !generated_rooms.has(room_uid):
		Logger.log_e(_pre_log + "The room with uid: %s does not exist" % room_uid)
		return "NO_ROOM_WITH_UID"
	var room : Room = generated_rooms[room_uid]
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
	Logger.log_v(_pre_log + "Room eligible %s : %s" % [attribute_id, str(eligible_properties_id)])
	var picked_property = _pick_property(category, attribute_id, eligible_properties_id, weight_contest)
	if picked_property == null:
		Logger.log_v(_pre_log + "No suitable %s found for room" % attribute_id)
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
func _property_conditions_met(category_dic : Dictionary, attribute_id : String, property_id : String, room : Room) -> bool:
	var conditions = _room_datasource.get_property_value(category_dic, attribute_id, property_id, "conditions")
	var counter_conditions = _room_datasource.get_property_value(category_dic, attribute_id, property_id, "counter_conditions")

	# Means the value has no conditions, and is therefore always possible
	if conditions == null && counter_conditions == null:
		Logger.log_v(_pre_log + property_id + " has no conditions or counter-conditions, it is a match by default")
		return true
	
	# "conditions" : {
	# 	"tone" : {
	# 		"smell" : ["this_id", "that_id"],
	# 		"air_quality" : ["this_id", "that_id"]
	# 	}
	# }
	if conditions != null:
		for category in conditions.keys():
			var room_category = room.room_properties.get(category)
			# If the room doesn't have that template, then it's not a match
			if room_category == null:
				Logger.log_v(_pre_log + "The room does not have the category: %s. It does not meet the required conditions for %s" % [category, property_id])
				return false

			for condition_attribute_id in conditions[category].keys():
				var room_property_id = room_category.get(condition_attribute_id)

				# The room doesn't have that attribute, it's not a match e.g. ("air_quality")
				if room_property_id == null:
					Logger.log_v(_pre_log + "Room does not have attribute (%s). It does not meet the required conditions for %s" % [condition_attribute_id, property_id])
					return false

				if !room_property_id in conditions[category][condition_attribute_id]:
					Logger.log_v(_pre_log + "Room does not have property in (%s). It does not meet the required conditions for %s" % [str(conditions[category][condition_attribute_id]), property_id])
					return false


	if counter_conditions != null:
		for category in counter_conditions.keys():
			var room_category = room.room_properties.get(category)
			# If the room doesn't have that template, it could match the counter-conditions
			if room_category == null:
				Logger.log_v(_pre_log + "Room does not have the category %s, fits counter condition" % category)
				continue

			for condition_attribute_id in counter_conditions[category].keys():
				var room_property_id = room_category.get(condition_attribute_id)

				# The room doesn't have that property, it's not a match
				if room_property_id == null:
					continue

				if room_property_id in counter_conditions[category][condition_attribute_id]:
					Logger.log_v(_pre_log + "Room has %s its a counter condition. It does not meet the required conditions for %s" % [room_property_id, property_id])
					return false

	return true
