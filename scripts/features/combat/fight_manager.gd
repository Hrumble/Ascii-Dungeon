class_name FightManager extends Node

var current_fight : Fight = null

var _player_manager : PlayerManager
const _PRE_LOG : String = "FightManager> "

## Emits when a fight starts
signal fight_started(fight : Fight)
## Emits when a fight ends
signal fight_ended

func _ready():
	_player_manager = GameManager.get_player_manager()

## Starts a fight with entity `opponent`, ensure it is an instance and not the class itself
func start_fight(opponent : Entity):
	if _player_manager.current_state != GlobalEnums.PlayerState.WANDERING:
		GlobalLogger.log_w(_PRE_LOG + "Attempted to start a fight, but the player is not wandering, quitting.")
		pass

	current_fight = Fight.new(opponent)
	GlobalLogger.log_i(_PRE_LOG + "Fight has begun with entity: %s" % opponent.display_name)
	_player_manager.set_state(GlobalEnums.PlayerState.FIGHTING)
	fight_started.emit(current_fight)

## Ends the ongoing fight, if there is no ongoing fight, does nothing
func end_current_fight():
	if current_fight == null:
		GlobalLogger.log_w(_PRE_LOG + "Cannot end fight, there is no fight.")
		return

	current_fight = null
	_player_manager.set_to_previous_state()
	fight_ended.emit()
