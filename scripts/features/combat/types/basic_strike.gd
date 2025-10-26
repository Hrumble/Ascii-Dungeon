extends CombatMove

var target_x : int
var target_y : int

func _execute(fight : Fight, is_opponent : bool):
	fight.deal_damage("penis", !is_opponent)
		
