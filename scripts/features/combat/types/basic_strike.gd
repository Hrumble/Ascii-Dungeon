extends CombatMove

var target_x : int
var target_y : int

func _execute(fight : Fight, is_opponent : bool):
	if is_opponent:
		fight.deal_damage(fight.opponent.get_weapon(), !is_opponent)
	else:
		fight.deal_damage(GameManager.get_player_manager().player.get_weapon(), !is_opponent)

		
