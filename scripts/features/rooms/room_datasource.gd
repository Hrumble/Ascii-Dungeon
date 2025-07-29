class_name RoomDatasource extends Node

signal room_datasource_ready

const _pre_log : String = "RoomDatasource> "
const _PROPERTY_PREFIX : String = "room_"
const _ROOMS_DIR : String = "res://rooms"
const _TEMPLATES_DIR : String = "/templates"
const _SETTINGS_DIR : Dictionary = {
	TONE = "/tone",
	INFO = "/info",
	ENTITIES = "/entities"
}

## Stores all the possible room tones
var room_tones : Dictionary = {}
## Stores all the possible info
var room_info : Dictionary = {}
## Stores all the possible entities
var room_entities : Dictionary = {}

func initialize():
	Logger.log_i(_pre_log + "Initializing RoomDatasource...")
	_load_room_categories()
	await get_tree().process_frame
	room_datasource_ready.emit()
	pass

## Loads the room properties into memory
func _load_room_categories():
	_load_room_category(room_tones, _SETTINGS_DIR.TONE)
	_load_room_category(room_info, _SETTINGS_DIR.INFO)
	pass

func _load_room_category(category_dic : Dictionary, settings_dir : String):
	var dir : String = _ROOMS_DIR + _TEMPLATES_DIR + settings_dir
	var file_names : PackedStringArray = DirAccess.get_files_at(dir)
	for file_name in file_names:
		# Ignore files that don't start with the proper prefix
		if !file_name.begins_with(_PROPERTY_PREFIX):
			continue
		var file_path : String = dir + "/" + file_name
		# goes from room_air_quality.json -> air_quality 
		var tone_property_id : String = file_name.get_basename().substr(_PROPERTY_PREFIX.length())
		var tone_property_json : String = FileAccess.get_file_as_string(file_path)
		# If opening file fails for some reason
		if tone_property_json == "":
			Logger.log_e(_pre_log + "Failed to open " + file_path)
			continue
		var parsed_json : Dictionary = JSON.parse_string(tone_property_json)
		if parsed_json == null:
			Logger.log_e(_pre_log + "Failed to parse json for " + file_path)
			continue

		# Creates an empty dictionnary for the tone we're about to define
		category_dic[tone_property_id] = {}
		for property_id in parsed_json.keys():
			category_dic[tone_property_id][property_id] = parsed_json[property_id]
	Logger.log_i(_pre_log + "Loaded properties: " + str(category_dic.keys()))
	pass

## Return a random value's ID from an attribute
func get_random_value_id(category_dic : Dictionary, attribute_id : String) -> String:
	var property_values = category_dic.get(attribute_id)
	if property_values == null:
		Logger.log_e(_pre_log + "Could not find (%s) " % attribute_id)
		return "NO_ID"
	property_values = property_values as Dictionary
	return property_values.keys().pick_random()

func get_properties_id(category_dic : Dictionary, attribute_id : String):
	var properties = category_dic.get(attribute_id)
	if properties == null:
		Logger.log_e(_pre_log + "Could not find (%s) in the provided dictionary" % attribute_id)
		return null
	return properties

## Returns the value of a property
func get_property(category_dic : Dictionary, attribute_id : String, property_id : String):
	var attribute = category_dic.get(attribute_id)
	if attribute == null:
		Logger.log_e(_pre_log + "the provided category does not contain the property (%s)" % attribute_id)
		return null
	var property = attribute.get(property_id)
	if property == null:
		Logger.log_e(_pre_log + "%s does not contain a value (%s)" % [attribute_id, property_id])
		return null
	return property

## Returns a specific field of the value, if the field is not specified, returns the "description" by default.
func get_property_value(category_dic : Dictionary, attribute_id : String, property_id : String, value_field : String = "description"):
	var value = get_property(category_dic, attribute_id, property_id)
	if value == null:
		return null
	var content = value.get(value_field)
	if content == null:
		Logger.log_e(_pre_log + property_id + " does not contain a field with key " + value_field + " Sometimes, this can be intentional, Ignore.")
		return null
	return content
