class_name FightManager extends Node

const _PRE_LOG : String = "FightManager> "

var current_fight : Fight = null
var _game_ui : MainGameUI 

signal fight_manager_ready

func initialize():
	Logger.log_i(_PRE_LOG + "Initializing FightManager...")
	_game_ui = GameManager.get_ui()
	await get_tree().process_frame
	fight_manager_ready.emit()

func start_fight(opponent : Entity):
	var player_manager : PlayerManager = GameManager.get_player_manager()
	player_manager.set_state(player_manager.PlayerState.FIGHTING)
	current_fight = Fight.new(opponent)
	current_fight.on_fight_end.connect(end_fight)
	_game_ui.log_handler.add_log(Log.new("Fight Started", "A fight with %s has begun" % opponent.display_name))
	pass

func end_fight(player_won : bool):
	pass
