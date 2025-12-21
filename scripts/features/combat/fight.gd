class_name Fight extends Node

const _PRE_LOG : String = "Fight> "

var opponent : Entity

var _current_player_sequence : Array[CombatMove] = []
var _current_opponent_sequence : Array[CombatMove] = []

var _current_turn : int = 0
var _player_won : bool = false

## Do not reference directly, use `_get_player_manager()` instead
var _player_manager : PlayerManager

signal on_fight_end(player_won : bool)
signal step_started(index : int)
signal sequence_done
## When the opponent's sequence is generated
signal opponent_sequence_set(sequence: Array[CombatMove])

func _init(_oponent : Entity):
	opponent = _oponent

## Plays the turn, then check if fight ends.
func play_turn():
	_run_sequence()
	next_turn()

func next_turn():
	_get_player_manager().player.current_sp = _get_player_manager().player.base_sp
	_current_turn += 1

## Ends the fight prematurely
func end_fight():
	GlobalLogger.log_d("Fight> Fight ended")
	on_fight_end.emit(_player_won)
	pass

## Adds a move to the sequence of a mob
func add_to_sequence(_move : CombatMove, position : int, is_opponent : bool = false):
	GlobalLogger.log_i(_PRE_LOG + "Adding %s to sequence at position %s" % [_move.display_name, position])
	if is_opponent:
		_current_opponent_sequence.insert(position, _move)
	else:
		_current_player_sequence.insert(position, _move)
		_get_player_manager().player.current_sp -= _move.get_sp_cost(self)
		_move.on_select(self)

## Removes a move from the sequence of a mob
func remove_from_sequence(position : int, is_opponent : bool = false):
	GlobalLogger.log_i(_PRE_LOG + "Removing move at position %s" % position)
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

func _check_fight_end():
	GlobalLogger.log_i("Checking for fight end...")
	if _get_player_manager().player.current_health <= 0: 
		_player_won = false
		GlobalLogger.log_i("Fight ended, player won?: %s" % _player_won)
		on_fight_end.emit(_player_won)	
		return
	if opponent.current_health <= 0:
		opponent.die()
		_player_manager.current_room.queue_update_description()
		# queue update room description
		_player_won = true
		GlobalLogger.log_i("Fight ended, player won?: %s" % _player_won)
		on_fight_end.emit(_player_won)	
		return
	GlobalLogger.log_i("The fight is still going")
		
func _generate_opponent_sequence():
	GlobalLogger.log_i(_PRE_LOG + "Generating opponent sequence")
	_current_opponent_sequence = opponent.generate_fight_sequence(self)
	pass

## Runs the opponent's sequence and the player's sequence
func _run_sequence():
	GlobalLogger.log_i(_PRE_LOG + "Preparing to run the move sequences...")
	_generate_opponent_sequence()
	opponent_sequence_set.emit(_current_opponent_sequence)
	await get_tree().create_timer(1).timeout

	# gets the number of moves in each sequence
	var opp_seq_size : int = _current_opponent_sequence.size()
	var player_seq_size : int = _current_player_sequence.size()
	var max_size : int = max(opp_seq_size, player_seq_size)

	for i in range(max_size):
		if i < player_seq_size:
			_current_player_sequence[i].pre_execute(self)
		if i < opp_seq_size:
			_current_opponent_sequence[i].pre_execute(self, true)
		_check_fight_end()
		# Ensure that the sequence has a move, else skips
		# For now, player technically goes first every time however, we do not `_check_fight_end()`, so it does not really matter
		step_started.emit(i)
		if i < player_seq_size:
			_current_player_sequence[i].execute(self)
		if i < opp_seq_size:
			_current_opponent_sequence[i].execute(self, true)
		_check_fight_end()
		await get_tree().create_timer(0.5).timeout

	# Empties both sequences
	_current_opponent_sequence.clear()
	_current_player_sequence.clear()
	sequence_done.emit()

#--------------------------------------------------------------------#
#                       Combat Move Callables                        #
#--------------------------------------------------------------------#

## Deal damage to entity
func deal_weapon_damage(weapon_id : String, to_opponent : bool):
	if weapon_id == "":
		GlobalLogger.log_i(_PRE_LOG + "The entity does not have a weapon equipped")
		return
	if to_opponent:
		opponent.take_hit(weapon_id)
	else:
		_get_player_manager().player.take_hit(weapon_id)

func deal_raw_damage(damage : float, to_opponent : bool):
	if to_opponent:
		opponent.take_raw_damage(damage)
	else:
		_get_player_manager().player.take_raw_damage(damage)
	pass
