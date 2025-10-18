class_name Fight

const _PRE_LOG : String = "Fight> "

var opponent : Entity

var opponent_position : Vector2i = Vector2i(2, 1)
var player_position : Vector2i = Vector2i(2, 3)

var _current_player_sequence : Array[CombatMove] = []
var _current_opponent_sequence : Array[CombatMove] = []

var _current_turn : int = 0
var _player_won : bool = false

## Do not reference directly, use `_get_player_manager()` instead
var _player_manager : PlayerManager

signal on_fight_end(player_won : bool)

func _init(_oponent : Entity):
	opponent = _oponent

## Plays the turn, then check if fight ends.
func play_turn():
	_run_sequence()
	next_turn()

func next_turn():
	if _check_fight_end():
		end_fight()
	_current_turn += 1

## Ends the fight prematurely
func end_fight():
	Logger.log_d("Fight> Fight ended")
	on_fight_end.emit(_player_won)
	pass

## Returns the player manager
func _get_player_manager() -> PlayerManager:
	if _player_manager == null:
		_player_manager = GameManager.get_player_manager()
	return _player_manager

func _check_fight_end() -> bool:
	if _get_player_manager().player.health <= 0: 
		_player_won = false
		return true
	if opponent.current_health <= 0:
		_player_won = true
		return true
	return false

func _generate_opponent_sequence():
	_current_opponent_sequence = opponent.generate_fight_sequence(self)
	pass

## Runs the opponent's sequence and the player's sequence
func _run_sequence():
	_generate_opponent_sequence()
	# gets the number of moves in each sequence
	var opp_seq_size : int = _current_opponent_sequence.size()
	var player_seq_size : int = _current_player_sequence.size()
	var max_size : int = max(opp_seq_size, player_seq_size)

	for i in max_size:
		# Ensure that the sequence has a move, else skips
		# For now, player technically goes first every time however, we do not `_check_fight_end()`, so it does not really matter
		if !i >= player_seq_size:
			_current_player_sequence[i].execute(self)
		if !i >= opp_seq_size:
			_current_opponent_sequence[i].execute(self, true)
			
##########################################
###### Combat Move Callables #############
##########################################
	
## Moves the player to (target_x, target_y), errors if t_x * t_y > 9
func set_pos(target_x : int, target_y : int, is_opponent : bool):
	if target_x * target_y > 9:
		Logger.log_w(_PRE_LOG + "Cannot move player to (%s, %s), out of bounds" % [target_x, target_y])
		return
	if is_opponent:
		opponent_position = Vector2i(target_x, target_y)
	else:
		player_position = Vector2i(target_x, target_y)
	pass

## The player uses his weapon on square(s) `target` : Array[Vector2i]
## Opponent takes his if its position is in the array
func deal_damage(weapon_id : String, target : Array[Vector2i], is_opponent : bool):
	var pos : Vector2i
	if is_opponent:
		pos = opponent_position
	else:
		pos = player_position
	if !pos in target:
		return
	if is_opponent:
		opponent.take_hit(weapon_id)
	else:
		_get_player_manager().player.take_hit(weapon_id)
