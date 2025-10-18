extends Node

var _pre_log : String = "GameManager> "

# Main game UI
@export var _game_ui_scene : PackedScene

@export var _dialogue_datasource : DialogueDatasource
@export var _registry : Registry
@export var _dialogue_manager : DialogueManager
@export var _entity_datasource : EntityDatasource
@export var _item_datasource : ItemDatasource
@export var _dialogue_event_manager : DialogueEventManager
@export var _player_manager : PlayerManager
@export var _command_handler : CommandHandler
@export var _room_datasource : RoomDatasource
@export var _room_handler : RoomHandler
@export var _fight_manager : FightManager
@export var _combat_move_datasource : CombatMoveDatasource

var _game_ui : MainGameUI = null

var _is_saved_game : bool

func _ready():

	# Initialize game manager
	Logger.log_i(_pre_log + "Starting game manager...")
	
	# Checks if a save exists
	_check_for_save()

	# Initializes the game registry
	_registry.initialize()
	await _registry.registry_ready

	# Initializes datasources
	_dialogue_datasource.initialize()
	await _dialogue_datasource.dialogue_datasource_ready

	_entity_datasource.initialize()
	await _entity_datasource.entity_datasource_ready

	_item_datasource.initialize()
	await _item_datasource.item_datasource_ready

	_room_datasource.initialize()
	await _room_datasource.room_datasource_ready

	_combat_move_datasource.initialize()
	await _combat_move_datasource.combat_move_datasource_ready

	# Initializes the player manager
	_player_manager.initialize()
	await _player_manager.player_manager_ready

	# Initializes dialogue_system
	_dialogue_manager.initialize()
	await _dialogue_manager.dialogue_system_ready

	# Initializes the Fight Manager
	_fight_manager.initialize()
	await  _fight_manager.fight_manager_ready

	# Initializes handlers
	_command_handler.initialize()
	await _command_handler.command_handler_ready

	_room_handler.initialize()
	await _room_handler.room_handler_ready

	# Starts the main game UI
	_game_ui = _game_ui_scene.instantiate()
	add_child(_game_ui)

	# Initializes the dialogue event manager It needs to be initialized last as it can reference anything
	_dialogue_event_manager.initialize()
	await _dialogue_event_manager.dialogue_event_manager_ready

	# If no saved games have been found, then it's the first launch
	if not _is_saved_game:
		_call_first_launch()

## Returns the combat move datasource
func get_combat_move_datasource():
	if _combat_move_datasource == null:
		Logger.log_e(_pre_log + "Tried getting the _combat_move_datasource, but it hasn't been set yet")
		return null
	return _combat_move_datasource

## Returns the main game UI instance if it exists, else returns null
func get_ui() -> MainGameUI:
	if _game_ui == null :
		Logger.log_w(_pre_log + "Careful, the game UI has not been instantiated yet.")
	return _game_ui

## Returns a reference to the current PlayerManager
func get_player_manager() -> PlayerManager:
	if _player_manager == null:
		Logger.log_e(_pre_log + "Tried getting the _player_manager, but it hasn't been set yet")
		return null
	return _player_manager

func get_combat_manager() -> FightManager:
	if _fight_manager == null:
		Logger.log_e(_pre_log + "Tried to get the FightManager, but it hasn't been set yet")
		return null
	return _fight_manager

func get_registry() -> Registry:
	if _registry == null:
		Logger.log_e(_pre_log + "Tried getting the _registry, but it hasn't been set yet")
		return null
	return _registry

func get_dialogue_datasource() -> DialogueDatasource:
	if _dialogue_datasource == null:
		Logger.log_e(_pre_log + "Tried getting the _dialogue_datasource, but it hasn't been set yet")
		return null
	return _dialogue_datasource

func get_room_datasource() -> RoomDatasource:
	if _room_datasource == null:
		Logger.log_e(_pre_log + "Tried getting the _room_datasource, but it hasn't been set yet")
		return null
	return _room_datasource

func get_room_handler() -> RoomHandler:
	if _room_handler == null:
		Logger.log_e(_pre_log + "Tried getting the _room_handler, but it hasn't been set yet")
		return null
	return _room_handler

func get_dialogue_manager() -> DialogueManager:
	if _dialogue_manager == null:
		Logger.log_e(_pre_log + "Tried getting the _dialogue_manager, but it hasn't been set yet")
		return null
	return _dialogue_manager

func get_dialogue_event_manager() -> DialogueEventManager:
	if _dialogue_event_manager == null:
		Logger.log_e(_pre_log + "Tried getting the _dialogue_event_manager, but it hasn't been set yet")
		return null
	return _dialogue_event_manager

func get_command_handler() -> CommandHandler:
	if _command_handler == null:
		Logger.log_e(_pre_log + "Tried getting the _command_handler, but it hasn't been set yet")
		return null
	return _command_handler
		
func _call_first_launch():
	# _dialogue_manager.start_dialogue_by_name("guidance_spirit", "intro")
	var room_pos : Vector2i = _room_handler.generate_room_at(_player_manager.player.player_position)
	_player_manager.player.enter_room(room_pos)
	pass
		
func _check_for_save():
	# Write the logic later, for now returns false constantly
	Logger.log_i(_pre_log + "Checking for a saved game...")
	_is_saved_game = false
	pass
	
