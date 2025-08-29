class_name Room

const _pre_log : String = "Room> "

var _room_datasource : RoomDatasource
var has_front_path : bool
var has_left_path : bool
var has_right_path : bool
var has_back_path : bool

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

## Sets a particular property of a room
func set_property(category : String, attribute_id : String, property_id : String):
	if !room_properties.has(category):
		room_properties[category] = {}
	room_properties[category][attribute_id] = property_id

func get_room_description() -> String:
	var full_description : String = ""
	full_description += "The room is " 	
	# Tone description
	var room_tone : Dictionary = room_properties.get(RoomProperties.CATEGORY.TONE)
	for attribute_id in room_tone.keys():
		full_description += "%s " % _room_datasource.get_property_value(
				_room_datasource.room_tones,
				attribute_id,
				room_tone.get(attribute_id)
		)
	var room_info : Dictionary = room_properties.get(RoomProperties.CATEGORY.INFO)
	for attribute_id in room_info.keys():
		full_description += "%s " % _room_datasource.get_property_value(
			_room_datasource.room_info,
			attribute_id,
			room_info.get(attribute_id)
		)
	return full_description

func _to_string():
	return str(room_properties)
