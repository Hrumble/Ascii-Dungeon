class_name EntityDatasource extends Node

var _pre_log : String = "EntitiesDatasource> "
var entities_dir : String = "res://entities"

var registry : Registry 

signal entity_datasource_ready

func initialize():
	Logger.log_i(_pre_log + "Initializing entity datasource...")
	registry = GameManager.get_registry()
	_load_entities()

func _load_entities():
	Logger.log_i(_pre_log + "Loading entities...")
	var dir_access : DirAccess = DirAccess.open(entities_dir)
	if !dir_access:
		Logger.log_e(_pre_log + "Could not open the entities folder : "+ entities_dir)
		return
	Logger.log_i(_pre_log + "Beginning directory traversal...")
	dir_access.list_dir_begin()
	var entity_name : String = dir_access.get_next()
	while entity_name != "":
		var file_path : String = entities_dir + "/" + entity_name
		var entity : Entity = Entity.fromJSON(FileAccess.get_file_as_string(file_path))
		if entity == null:
			Logger.log_e(_pre_log + "Could not parse entity: " + entity_name)
		else:
			Logger.log_i(_pre_log + "Successfully parsed entity: %s > (%s)" % [entity_name, entity])
			Logger.log_v(_pre_log + "Adding %s to the registry" % entity.display_name)
			registry.add_to_registry(entity_name.get_basename(), entity)
		entity_name = dir_access.get_next()
	await get_tree().process_frame
	entity_datasource_ready.emit()
