## An instance of a fight
class_name Fight extends Node

# The fighting system, is in my mind very fun.
# A fight round is divided into `Events`, each event plays one after the other, and then repeats if none of the participants are dead
# Each event is modified by what the player has equipped on him
# The player doesn't interact, he watches it unfold.
# 
# The entire point is that the player must spend most of his time building the perfect combo of items and armors, so that everything works together.
# There is no limit to what the player can build, this is the magic
#
# (e.g. A weapon that consumes 10 meat, writes a quote to screen, then proceeds to make the player deal damage to himself is possible, and desirable)
#
# (as always all of this is hypothetical, I need to implement it now)
#
# You'll notice on each event, after emiting the signal, we await .2s then call `resolve_action`. The waiting is to ensure that everything gets added to the action_queue
# properly
const _PRE_LOG : String = "Fight> "

var _opponent : Entity = null
var _player_manager : PlayerManager = null

var _current_context : FightContext
var _current_step : int = 0
var sequencer : FightSequencer

signal on_turn_start(context : FightContext)
signal on_enemy_declared_intent(context : FightContext)
signal on_block_attempt(context : FightContext)
signal on_run_attacks(context : FightContext)
signal on_turn_end(context : FightContext)

signal fight_end

var steps : Array = [
	"_start_turn",
	"_declare_enemy_intent",
	"_attempt_block",
	"_run_attacks",
	"_end_turn"
]

## Plays the list of events
func start_fight():
	_current_context = FightContext.new()

	_current_context.player_manager = _player_manager
	_current_context.enemy = _opponent
	_current_context.fight = self
	_current_step = -1

	next_step()

## Plays the next step of the fight
func next_step():
	_current_step += 1
	_current_context.step = _current_step
	if _current_step >= steps.size():
		end_fight()
		return

	callv(steps[_current_step], [_current_context])

	await resolve_actions(_current_context)
	_current_context.action_queue.clear()

	next_step()

func _init(_opp : Entity):
	_opponent = _opp
	_player_manager = GameManager.get_player_manager()
	sequencer = FightSequencer.new()

	_setup()

func _setup():
	_player_manager.player.connect_to_fight(self)

func end_fight():
	GlobalLogger.log_i(_PRE_LOG + "Fight is ended.")
	fight_end.emit()
	pass

#--------------------------------------------------------------------#
#                               Events                               #
#--------------------------------------------------------------------#

func _start_turn(context : FightContext):
	GlobalLogger.log_i(_PRE_LOG + "Turn Started")
	on_turn_start.emit(context)

func _declare_enemy_intent(context : FightContext):
	GlobalLogger.log_i(_PRE_LOG + "Declaring intent")
	context.enemy_intent = _opponent.get_intent(context)
	GlobalLogger.log_i(_PRE_LOG + "Enemy intent declared: %s" % context.enemy_intent)
	on_enemy_declared_intent.emit(context)

func _attempt_block(context : FightContext):
	GlobalLogger.log_i(_PRE_LOG + "Block Attempts")
	on_block_attempt.emit(context)

func _run_attacks(context : FightContext):
	GlobalLogger.log_i(_PRE_LOG + "Running Attacks")
	context.enemy_move = _opponent.get_move(context)
	if !context.block_success and context.enemy_move != null:
		context.enemy_move.execute(context)	
	
	on_run_attacks.emit(context)

func _end_turn(context : FightContext):
	GlobalLogger.log_i(_PRE_LOG + "Ending turn")
	on_turn_end.emit(context)

#--------------------------------------------------------------------#
#                               Utils                                #
#--------------------------------------------------------------------#

func _check_health():
	if _player_manager.player.current_health <= 0:
		end_fight()
	if _opponent.current_health <= 0:
		end_fight()
	pass

func resolve_actions(ctx : FightContext):
	await sequencer.resolve_actions(ctx)

#--------------------------------------------------------------------#
#                              Actions                               #
#--------------------------------------------------------------------#

func heal(target : Entity, amount : float):
	pass
