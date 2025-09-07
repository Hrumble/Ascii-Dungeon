class_name Registry extends Node

var _pre_log : String = "Registry> "
var content : Dictionary

signal registry_ready

func initialize():
	Logger.log_i(_pre_log + "Initializing registry...")
	# Initialize all the objects of the game
	await get_tree().process_frame
	registry_ready.emit()
	pass

## Returns a registry entry by it's ID. Returns `null` if the id does not exist
func get_entry_by_id(id : String) -> Object:
	if not content.has(id):
		Logger.log_e(_pre_log + "entry with id (%s)" % id + " does not exist")
		return null
	var entry : Object = content[id]
	Logger.log_v(_pre_log + "Returning (%s) with id (%s)" % [entry, id])
	return entry

func get_entry_copy(id : String) -> Object:
	var entry : Object = content.get(id)
	if entry == null:
		Logger.log_e(_pre_log + "entry with id (%s)" % id + " does not exist")
		return null
	var _duplicate : Object = entry.duplicate(true)
	Logger.log_v(_pre_log + "Returning duplicate: (%s)" % _duplicate)
	return _duplicate


## Adds an object to registry with the id.
## If the id already exists, it will not be overriten, the request will just be ignored
func add_to_registry(id : String, entry : Object):
	if content.has(id):
		Logger.log_e(_pre_log + "Attempted to add an entry to registry, but it's id already exists (%s)" %id)
		return
	Logger.log_v(_pre_log + id + " has been added to the registry, object: (%s)" % entry)
	content[id] = entry
	pass
