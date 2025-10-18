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

## Does the registry have an entry with id `id`
func has(id : String) -> bool:
	return content.has(id)

## Returns a registry entry by it's ID. Returns `null` if the id does not exist
func get_entry_by_id(id : String) -> Object:
	if not content.has(id):
		Logger.log_e(_pre_log + "entry with id (%s)" % id + " does not exist")
		return null
	var entry : Object = content[id]
	Logger.log_d(_pre_log + "Returning (%s) with id (%s)" % [entry, id])
	return entry

## Returns the copy of an entry inside the registry, returns `null` if the `id` does not exist
func get_entry_copy(id : String) -> Object:
	var entry : Object = content.get(id)
	if entry == null:
		Logger.log_e(_pre_log + "entry with id (%s)" % id + " does not exist")
		return null
	var _duplicate : Object = entry.duplicate(true)
	Logger.log_d(_pre_log + "Returning duplicate: (%s)" % _duplicate)
	return _duplicate

func get_entry_property(id : String, property : String):
	var entry : Object = content.get(id)
	if entry == null:
		Logger.log_e(_pre_log + "entry with id (%s)" % id + " does not exist")
		return null
	return entry.get(property)

## Adds an object to registry with the id.
## If the id already exists, it will not be overriten, the request will just be ignored
func add_to_registry(id : String, entry : Object):
	if content.has(id):
		Logger.log_e(_pre_log + "COLLISION, the id %s already exists in the registry" %id)
		return
	Logger.log_d(_pre_log + id + " has been added to the registry, object: (%s)" % entry)
	content[id] = entry
	pass
