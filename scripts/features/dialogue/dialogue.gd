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
		Logger.log_e("Could not parse json dialogue, ensure you didn't make any mistakes")
		return null
	var _dialogue_objects : Array[DialogueObject] = []
	for do : Dictionary in parsed_json["dialogue"]:
		var opt = null
		var event = null
		var event_params = null
		if do.has("options"):
			opt = do["options"]
		if do.has("event"):
			event = do["event"]
			if do.has("event_params"):
				event_params = do["event_params"]
		_dialogue_objects.append(DialogueObject.new(do["text"], opt, event, event_params))
	return Dialogue.new(_dialogue_objects)
