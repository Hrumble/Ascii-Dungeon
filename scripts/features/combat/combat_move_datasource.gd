class_name CombatMoveDatasource extends Node

var _pre_log : String = "CombatMoveDatasource> "
var moves_dir : String = "res://combat_moves"

var registry : Registry 

signal combat_move_datasource_ready

func initialize():
	GlobalLogger.log_i(_pre_log + "Initializing combat move datasource...")
	registry = GameManager.get_registry()
	_load_moves()

func _load_moves():
	GlobalLogger.log_i(_pre_log + "Loading moves...")
	var dir_access : DirAccess = DirAccess.open(moves_dir)
	if !dir_access:
		GlobalLogger.log_e(_pre_log + "Could not open the moves folder : "+ moves_dir)
		return
	GlobalLogger.log_i(_pre_log + "Beginning directory traversal...")
	dir_access.list_dir_begin()
	var move_name : String = dir_access.get_next()
	while move_name != "":
		var file_path : String = moves_dir + "/" + move_name
		var _move : CombatMove = CombatMove.fromJSON(FileAccess.get_file_as_string(file_path))
		if _move == null:
			GlobalLogger.log_e(_pre_log + "Could not parse move: " + move_name)
		else:
			GlobalLogger.log_i(_pre_log + "Successfully parsed move: %s > (%s)" % [move_name, _move])
			GlobalLogger.log_d(_pre_log + "Adding %s to the registry" % _move.display_name)
			registry.add_to_registry(move_name.get_basename(), _move)
		move_name = dir_access.get_next()
	await get_tree().process_frame
	GlobalLogger.log_i(_pre_log + "Done")
	combat_move_datasource_ready.emit()
