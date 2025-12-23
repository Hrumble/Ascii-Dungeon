## Contains a name and an array of [DialogueObjects]
class_name Dialogue


var dialogue_objects : Array

func _init(_dialogue_objects : Array[DialogueObject]):
	dialogue_objects = _dialogue_objects
	pass

## Returns a new Dialogue object from a json file
static func fromJSON(json : String) -> Dialogue:
	var parsed_json = JSON.parse_string(json)
	if parsed_json == null:
		GlobalLogger.log_e("Could not parse json dialogue, ensure you didn't make any mistakes")
		return null
	var _dialogue_objects : Array[DialogueObject] = []
	for dialogue_object : Dictionary in parsed_json["dialogue"]:
		var opt = null
		var event = null
		var event_params = null
		if dialogue_object.has("options"):
			opt = dialogue_object["options"]
		if dialogue_object.has("event"):
			event = dialogue_object["event"]
			if dialogue_object.has("event_params"):
				event_params = dialogue_object["event_params"]
		_dialogue_objects.append(DialogueObject.new(dialogue_object["text"], opt, event, event_params))
	return Dialogue.new(_dialogue_objects)
