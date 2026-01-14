class_name QueueAction

var source : Object
var action : String
var parameters : Array

func _init(_source : Object, _action : String, _parameters : Array):
	source = _source
	action = _action
	parameters = _parameters

func _to_string():
	return "QueueAction(source: %s, action: %s, parameters: %s)" % [source, action, parameters]

## Calls this action on object `_object`
func resolve(object : Object):
	if !object.has_method(action):
		GlobalLogger.log_e("Cannot call method %s on object %s, it does not exist" % [action, object])
		return

	if parameters.is_empty():
		object.call(action)
	else:
		object.callv(action, parameters)
