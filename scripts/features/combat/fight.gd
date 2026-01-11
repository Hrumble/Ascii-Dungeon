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
var opponent : Entity = null
var player_manager : PlayerManager = null

signal on_turn_start(context : FightContext)
signal on_enemy_declared_intent(context : FightContext)
signal on_block_attempt(context : FightContext)
signal on_run_attacks(context : FightContext)
signal on_turn_end(context : FightContext)

## Plays the list of events
func play_turn():
	var context : FightContext = FightContext.new()

	context.player = player_manager
	context.enemy = opponent
	context.fight = self

	_start_turn(context)
	await get_tree().create_timer(.5).timeout
	_declare_enemy_intent(context)
	await get_tree().create_timer(.5).timeout
	_attempt_block(context)
	await get_tree().create_timer(.5).timeout
	_run_attacks(context)
	await get_tree().create_timer(.5).timeout
	_end_turn(context)
	await get_tree().create_timer(.5).timeout

	_check_health()

func _init(_opponent : Entity):
	opponent = _opponent
	player_manager = GameManager.get_player_manager()

func setup():
	GameManager.get_player_manager().connect_to_fight(self)

func end_fight():
	pass

#--------------------------------------------------------------------#
#                               Events                               #
#--------------------------------------------------------------------#

func _start_turn(context : FightContext):
	on_turn_start.emit(context)
	pass

func _declare_enemy_intent(context : FightContext):
	context.enemy_intent = opponent.get_intent(context)
	on_enemy_declared_intent.emit(context)
	pass

func _attempt_block(context : FightContext):
	on_block_attempt.emit(context)
	pass

func _run_attacks(context : FightContext):
	context.enemy_move = opponent.get_move(context)
	if !context.block_success and context.enemy_move != null:
		context.enemy_move.execute(context)	
	
	on_run_attacks.emit(context)

func _end_turn(context : FightContext):
	on_turn_end.emit(context)
	pass

func _check_health():
	if player_manager.player.current_health <= 0:
		end_fight()
	if opponent.current_health <= 0:
		end_fight()
	pass
