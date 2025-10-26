class_name CombatMove
## A Class that encapsulates a move possible in combat
## Each move has an execute function which is called when this move is done by the player
## There is also an SP cost

##
var sp_cost : int = 0
var display_name : String
var description : String

static func fromJSON(json : String) -> CombatMove:
	var parsed_json = JSON.parse_string(json)
	if parsed_json == null:
		return null
	parsed_json = parsed_json as Dictionary

	## Check if entity specified a custom type
	var type = parsed_json.get("type")

	var _move : CombatMove

	if type != null:
		var _path : String = "res://scripts/features/combat/types/%s.gd" % type
		if !FileAccess.file_exists(_path):
			Logger.log_e("ParsingCombatMove> Failed to create move, the specifid file does not exist: " + _path)
			return null
		else:
			_move = load(_path).new()
	else:
		_move = CombatMove.new()

	_move.sp_cost = parsed_json.get("sp_cost", 0)
	_move.display_name = parsed_json.get("display_name", 0)
	_move.description = parsed_json.get("description", "Nothing to say about that...")

	if type != null:
		var type_properties = parsed_json.get("type_properties", {}) 
		for key in type_properties.keys():
			if key in _move:
				_move.set(key, type_properties[key])
			else:
				Logger.log_w("ParsingCombatMove> %s has no property called %s!" % [type, key])

	return _move

## What happens when this move is executed
func execute(fight : Fight, is_opponent : bool = false):
	_execute(fight, is_opponent)
	pass

## What happens when this move is executed, to be overriden
func _execute(_fight : Fight, _is_opponent : bool):
	pass

## What happens when the player selects this move from the list of available moves
func on_select(fight : Fight):
	_on_select(fight)

## What happens when the player selects this move from the list of available moves, to be overwriten
func _on_select(_fight : Fight):
	pass

## What happens when the player selects this move from the list of available moves
func on_deselect(fight : Fight):
	_on_deselect(fight)

## What happens when the player selects this move from the list of available moves, to be overwriten
func _on_deselect(_fight : Fight):
	pass

## Before this move gets executed, similar to a setup method
func pre_execute(fight : Fight, is_opponent : bool = false):
	_pre_execute(fight, is_opponent)
	pass

## Before this move gets executed, similar to a setup method, to be overwriten
func _pre_execute(_fight : Fight, _is_opponent : bool):
	pass

## The cost in SP of this move
func get_sp_cost(fight : Fight) -> int:
	return _get_sp_cost(fight)

## The cost in SP of this move, to be overriden
func _get_sp_cost(fight : Fight) -> int:
	return sp_cost
