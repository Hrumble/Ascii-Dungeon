class_name FightManager extends Node

const _PRE_LOG: String = "FightManager> "

var current_fight: Fight = null
var _game_ui: MainGameUI

signal fight_manager_ready
## Fires when a fight begins with an `oponent` [Entity]
signal fight_started(oponent: Entity)
## Fires when a fight ends with an `oponent` [Entity]
signal fight_ended(oponent: Entity, _player_won: bool)


func initialize():
	Logger.log_i(_PRE_LOG + "Initializing FightManager...")
	_game_ui = GameManager.get_ui()
	await get_tree().process_frame
	fight_manager_ready.emit()


func start_fight(opponent: Entity):
	var player_manager: PlayerManager = GameManager.get_player_manager()
	player_manager.set_state(GlobalEnums.PlayerState.FIGHTING)
	current_fight = Fight.new(opponent)
	current_fight.on_fight_end.connect(end_fight)
	_game_ui.new_log(
		Log.new("Fight Started", "A fight with %s has begun" % opponent.display_name)
	)
	fight_started.emit(opponent)
	pass


func end_fight(player_won: bool = true):
	fight_ended.emit(current_fight.opponent, player_won)
	pass
