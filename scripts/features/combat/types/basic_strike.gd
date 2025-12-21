extends CombatMove

var damage : float = 1

func _execute(fight : Fight, is_opponent : bool):
	fight.deal_raw_damage(damage, !is_opponent)

		
