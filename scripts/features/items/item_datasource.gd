class_name ItemDatasource extends Node

var _pre_log : String = "ItemDatasource> "
var items_dir : String = "res://items"
# var texture_dir : String = "/textures"
var registry : Registry 

signal item_datasource_ready

func initialize():
	Logger.log_i(_pre_log + "Initializing item datasource...")
	registry = GameManager.get_registry()
	# texture_dir = items_dir + texture_dir
	_load_items()

func _load_items():
	Logger.log_i(_pre_log + "Loading items...")
	var dir_access : DirAccess = DirAccess.open(items_dir)
	if !dir_access:
		Logger.log_e(_pre_log + "Could not open the items folder : "+ items_dir)
		return
	Logger.log_i(_pre_log + "Beginning directory traversal...")
	dir_access.list_dir_begin()
	var item_id : String = dir_access.get_next()
	while item_id != "":
		if dir_access.current_is_dir():
			item_id = dir_access.get_next()
			continue
		var file_path : String = items_dir + "/" + item_id
		var item  : Item = Item.fromJSON(FileAccess.get_file_as_string(file_path))
		if item == null:
			Logger.log_e(_pre_log + "Could not parse item: " + item_id)
		else:
			Logger.log_i(_pre_log + "Successfully parsed item: " + item_id)
			Logger.log_d(_pre_log + "Adding %s to the registry" % item_id.get_basename())
			registry.add_to_registry(item_id.get_basename(), item)
		item_id = dir_access.get_next()
	await get_tree().process_frame
	item_datasource_ready.emit()

