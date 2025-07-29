class_name RoomHandler extends Node

signal room_handler_ready
const _pre_log : String = "RoomHandler> "

var _room_datasource : RoomDatasource

func initialize():
	_room_datasource = GameManager.get_room_datasource()
	await get_tree().process_frame
	room_handler_ready.emit()

func generate_random_room():
	var room : Room = Room.new()
	for property_id in RoomProperties.TONE_ID.values():
		var random_value : String = _room_datasource.get_random_value_id(_room_datasource.room_tones, property_id)
		room.set_property(RoomProperties.CATEGORY.TONE, property_id, random_value) 
	_generate_room_info(room)
	Logger.log_i(_pre_log + "Room generated : " + str(room))
	## Check each property in dic, if property is possible here, add it to an array
	## evaluate chance of each and choose one
	return room

func _generate_room_info(room : Room):
	var populations = _room_datasource.get_properties_id(_room_datasource.room_info, RoomProperties.INFO_ID.POPULATION)
	if populations == null:
		Logger.log_e(_pre_log + "Error has occured when trying to add a population")
		return
	var eligible_population_id : Array = []
	for population_id in populations.keys():
		if _property_conditions_met(_room_datasource.room_info, RoomProperties.INFO_ID.POPULATION, population_id, room):
			eligible_population_id.append(population_id)
	Logger.log_v(_pre_log + "room eligible populations : " + str(eligible_population_id))
	var picked_population = _pick_property(_room_datasource.room_info, RoomProperties.INFO_ID.POPULATION, eligible_population_id)
	if picked_population == null:
		Logger.log_v(_pre_log + "No suitable population found for room")
	else:
		room.set_property(RoomProperties.CATEGORY.INFO, RoomProperties.INFO_ID.POPULATION, picked_population)


## Picks a single property from an array of eligible ones based on chance and weight. 
## the properties MUST have a "chance" and "weight" key on the first nesting layer.
func _pick_property(category_dic : Dictionary, attribute_id : String, property_ids : Array):
	var chances : Array = []
	for property_id in property_ids:
		var chance = _room_datasource.get_property_value(category_dic, attribute_id, property_id, "chance")
		if chance != null:
			chances.append(chance)
	var eligible_ids : Array = Utils.pick_from_chance(property_ids, chances)
	var weights : Array = []
	for property_id in eligible_ids:
		var weight = _room_datasource.get_property_value(category_dic, attribute_id, property_id, "weight")
		if weight != null:
			weights.append(weight)

	return Utils.pick_from_weight(eligible_ids, weights)


## Verifies if the `conditions` and `counter_conditions` keys of a property are met by the room
func _property_conditions_met(category_dic : Dictionary, attribute_id : String, property_id : String, room : Room) -> bool:
	var conditions = _room_datasource.get_property_value(category_dic, attribute_id, property_id, "conditions")
	var counter_conditions = _room_datasource.get_property_value(category_dic, attribute_id, property_id, "counter_conditions")

	# Means the value has no conditions, and is therefore always possible
	if conditions == null && counter_conditions == null:
		Logger.log_v(_pre_log + property_id + " has no conditions, it is a match")
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
				Logger.log_v(_pre_log + "The room does not have the category: %s. It does not meet the required conditions" % category)
				return false

			for condition_attribute_id in conditions[category].keys():
				var room_property_id = room_category.get(condition_attribute_id)

				# The room doesn't have that attribute, it's not a match e.g. ("air_quality")
				if room_property_id == null:
					Logger.log_v(_pre_log + "Room does not have attribute (%s). It does not meet the required conditions" % condition_attribute_id)
					return false

				if !room_property_id in conditions[category][condition_attribute_id]:
					Logger.log_v(_pre_log + "Room does not have property in (%s). It does not meet the required conditions" % str(conditions[category][condition_attribute_id]))
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
					Logger.log_v(_pre_log + "Room has %s its a counter condition. It does not meet the required conditions" % [room_property_id])
					return false

	return true
