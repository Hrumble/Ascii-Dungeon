class_name Registry extends Node

var _pre_log : String = "Registry> "
var content : Dictionary[String, Object]

signal registry_ready

func initialize():
	GlobalLogger.log_i(_pre_log + "Initializing registry...")
	# Initialize all the objects of the game
	await get_tree().process_frame
	registry_ready.emit()
	pass

## Does the registry have an entry with id `id`
func has(id : String) -> bool:
	return content.has(id)

## Returns every single entry of this registy
func get_all_entries() -> Array[Object]:
	return content.values()

## Returns all registry entries of type `type`.
## `type` must be a [String] specified type such as `Item` or `Entity`
##
## If the type does not exist, an empty array is returned
func get_entries_of_type(type : String) -> Array[Object]:
	var arr : Array = []
	for obj : Object in content.values():
		if obj.is_class(type):
			arr.append(type)
	
	return arr

## Returns all registry entries which id or name fuzzy matches `search`
func search_entries(search : String) -> Array[Object]:
	var search_results : Array[Object] = []
	for key in content.keys():
		var object : Object = content[key]

		if search in key:
			search_results.append(object)
			continue
		var object_name = object.get("display_name")
		if object_name != null and search in object_name:
			search_results.append(object)
			continue

	return search_results

## Returns a registry entry by it's ID. Returns `null` if the id does not exist
func get_entry_by_id(id : String) -> Object:
	if not content.has(id):
		GlobalLogger.log_e(_pre_log + "entry with id (%s)" % id + " does not exist")
		return null
	var entry : Object = content[id]
	GlobalLogger.log_d(_pre_log + "Returning (%s) with id (%s)" % [entry, id])
	return entry

## Returns the copy of an entry inside the registry, returns `null` if the `id` does not exist
func get_entry_copy(id : String) -> Object:
	var entry : Object = content.get(id)
	if entry == null:
		GlobalLogger.log_e(_pre_log + "entry with id (%s)" % id + " does not exist")
		return null
	var _duplicate : Object = entry.duplicate(true)
	GlobalLogger.log_d(_pre_log + "Returning duplicate: (%s)" % _duplicate)
	return _duplicate

func get_entry_property(id : String, property : String):
	var entry : Object = content.get(id)
	if entry == null:
		GlobalLogger.log_e(_pre_log + "entry with id (%s)" % id + " does not exist")
		return null
	return entry.get(property)

## Adds an object to registry with the id.
## If the id already exists, it will not be overwriten, the request will just be ignored
func add_to_registry(id : String, entry : Object):
	if not (entry.get("id")):
		GlobalLogger.log_e(_pre_log + "Cannot add entry id(%s), it does not contain an `id` parameter." % id)
	if content.has(id):
		GlobalLogger.log_e(_pre_log + "COLLISION, the id %s already exists in the registry" %id)
		return
	GlobalLogger.log_d(_pre_log + id + " has been added to the registry, object: (%s)" % entry)
	content[id] = entry
	pass
