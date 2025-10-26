class_name Fight

const _PRE_LOG : String = "Fight> "

var opponent : Entity

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

## Adds a move to the sequence of a mob
func add_to_sequence(_move : CombatMove, position : int, is_opponent : bool = false):
	Logger.log_i(_PRE_LOG + "Adding %s to sequence at position %s" % [_move.display_name, position])
	if is_opponent:
		_current_opponent_sequence.insert(position, _move)
	else:
		_current_player_sequence.insert(position, _move)
		_get_player_manager().player.current_sp -= _move.get_sp_cost(self)
		_move.on_select(self)

## Removes a move from the sequence of a mob
func remove_from_sequence(position : int, is_opponent : bool = false):
	Logger.log_i(_PRE_LOG + "Removing move at position %s" % position)
	if is_opponent:
		_current_opponent_sequence.remove_at(position)
	else:
		var _move : CombatMove = _current_player_sequence.pop_at(position)
		_get_player_manager().player.current_sp += _move.get_sp_cost(self)
		_move.on_deselect(self)

## Sets a sequence to a list of moves, avoids having to manually add each
func set_sequence(_moves : Array[CombatMove], is_opponent : bool = false):
	if is_opponent:
		_current_opponent_sequence = _moves
	else:
		_current_player_sequence = _moves

## Returns the sequence of an entity
func get_sequence(is_opponent : bool) -> Array[CombatMove]:
	if is_opponent:	
		return _current_player_sequence
	return _current_opponent_sequence

## Returns the player manager
func _get_player_manager() -> PlayerManager:
	if _player_manager == null:
		_player_manager = GameManager.get_player_manager()
	return _player_manager

func _check_fight_end() -> bool:
	if _get_player_manager().player.current_health <= 0: 
		_player_won = false
		return true
	if opponent.current_health <= 0:
		_player_won = true
		return true
	return false

func _generate_opponent_sequence():
	Logger.log_i(_PRE_LOG + "Generating opponent sequence")
	_current_opponent_sequence = opponent.generate_fight_sequence(self)
	pass

## Runs the opponent's sequence and the player's sequence
func _run_sequence():
	Logger.log_i(_PRE_LOG + "Preparing to run the move sequences...")
	_generate_opponent_sequence()
	# gets the number of moves in each sequence
	var opp_seq_size : int = _current_opponent_sequence.size()
	var player_seq_size : int = _current_player_sequence.size()
	var max_size : int = max(opp_seq_size, player_seq_size)

	for i in range(max_size):
		print("%s: %s, %s" % [i, _current_player_sequence, _current_opponent_sequence])
		if i < player_seq_size:
			_current_player_sequence[i].pre_execute(self)
		if i < opp_seq_size:
			_current_opponent_sequence[i].pre_execute(self, true)
		# Ensure that the sequence has a move, else skips
		# For now, player technically goes first every time however, we do not `_check_fight_end()`, so it does not really matter
		if i < opp_seq_size:
			_current_player_sequence[i].execute(self)
		if i < opp_seq_size:
			_current_opponent_sequence[i].execute(self, true)

			
##########################################
###### Combat Move Callables #############
##########################################
	
## The player uses his weapon on square(s) `target` : Array[Vector2i]
## Opponent takes his if its position is in the array
func deal_damage(weapon_id : String, to_opponent : bool):
	if to_opponent:
		opponent.take_hit(weapon_id)
	else:
		_get_player_manager().player.take_hit(weapon_id)
