class_name Fight

var opponent : Entity
var _current_turn : int = 0
var _player_won : bool = false

signal on_fight_end(player_won : bool)

func _init(_oponent : Entity):
	opponent = _oponent

func next_turn():
	if _check_fight_end():
		end_fight()
	_current_turn += 1

func end_fight():
	Logger.log_d("Fight> Fight ended")
	on_fight_end.emit(_player_won)
	pass

func _check_fight_end() -> bool:
	if GameManager.get_player_manager().player.health <= 0: 
		_player_won = false
		return true
	if opponent.current_health <= 0:
		_player_won = true
		return true
	return false

	
