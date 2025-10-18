extends CombatMove

var target_x : int
var target_y : int
var distance_based_sp_cost : bool

func _execute(fight : Fight, is_opponent : bool):
	fight.set_pos(target_x, target_y, is_opponent)

func _get_sp_cost(fight : Fight) -> int:
	if !distance_based_sp_cost:
		return sp_cost
	return (fight.player_position - Vector2i(target_x, target_y)).length()


		
