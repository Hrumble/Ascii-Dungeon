### A class to store a single dialogue object
###
### A dialogue object is the text that the character will say, as well as the options available to the player
### options can be either an Array of String, or null, when no options are available
class_name DialogueObject extends Node

var text : String
var options
var event
var event_params
var has_event : bool = false

func _init(_text : String, _options, _event, _event_params):
	text = _text
	options = _options
	event = _event
	event_params = _event_params
	if event != null:
		has_event = true
