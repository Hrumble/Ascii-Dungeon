## A container which holds all the combat moves of an entity
class_name CombatMoveContainer

## Stores the available moves
var available_moves : Dictionary[String, bool] = {}

## Adds a move to the container
func add_move(move_id : String):
	if !GameManager.get_registry().has(move_id):
		Logger.log_e("CombatMoveContainer cannot add move with id : %s because it does not exist in the registry" % move_id)
		return
	available_moves[move_id] = true

## Removes a move from the container
func remove_move(move_id : String):
	if !has(move_id):
		Logger.log_w("CombatMoveContainer attempted to remove a move that is not in the container: %s" % move_id)
		return
	available_moves.erase(move_id)

func has(move_id : String) -> bool:
	return available_moves.has(move_id)

## Returns a reference to the move object inside the container
## Returns `null` if the move_id is not available
func get_ref(move_id : String) -> CombatMove:
	if !has(move_id):
		Logger.log_w("CombatMoveContainer cannot get ref for %s because it is not available" % move_id)
		return null
	return GameManager.get_registry().get_entry_by_id(move_id)
