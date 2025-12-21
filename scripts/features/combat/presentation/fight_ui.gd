class_name FightUI extends Control

const _PRE_LOG : String = "FightUI> "
@export var _entity_combat_container_scene : PackedScene
@export var _player_container : Control
@export var _opponent_container : Control
@export var _run_sequence_button : Button
@export var _entity_die_screen : EntityDieScreenUI
@export var _fight_container : Control

var _player_combat_container : EntityCombatContainerUI
var _enemy_combat_container : EntityCombatContainerUI

var _player_move_container : CombatMoveContainer
var _fight : Fight

var _player_manager : PlayerManager

func _ready():
	pass

func open():
	# If player manager has still not been set, set it
	if _player_manager == null:
		_player_manager = GameManager.get_player_manager()
	GlobalLogger.log_i(_PRE_LOG + "Opening Fight UI...")
	_entity_die_screen.hide()
	_fight_container.show()

	_player_move_container = _player_manager.player.combat_move_container
	_fight = GameManager.get_combat_manager().current_fight
	_player_combat_container = _entity_combat_container_scene.instantiate()
	_enemy_combat_container = _entity_combat_container_scene.instantiate()
	_player_combat_container.setup(_player_manager.player, _fight)
	_enemy_combat_container.setup(_fight.opponent, _fight)

	_run_sequence_button.pressed.connect(func(): _fight.play_turn())
	_fight.on_fight_end.connect(_on_fight_end)

	_player_container.add_child(_player_combat_container)
	_opponent_container.add_child(_enemy_combat_container)
	
	show()
	await get_tree().process_frame
	grab_focus()

func _on_fight_end(player_won : bool):
	_fight_container.hide()
	if !player_won:
		_entity_die_screen.open("Player")
	else:
		_entity_die_screen.open(_fight.opponent.display_name)

func _gui_input(event):
	if event.is_action_pressed("ui_confirm"):
		var value = await GameManager.get_ui().open_telescope(_get_moves_options())
		if value != null:
			_add_move_to_sequence(value)
		await get_tree().process_frame
		grab_focus()

func update_health():
	pass

## Visually adds a move to the entity's sequence
func _add_move_to_sequence(_move : CombatMove):
	if _player_manager.player.current_sp < _move.get_sp_cost(_fight):
		return
	_fight.add_to_sequence(_move, _fight._current_player_sequence.size())
	_player_combat_container.add_to_sequence(_move)
	pass

## Gets all the move options available to the player as [TelescopeOption]s
func _get_moves_options() -> Array[TelescopeOption]:
	var options : Array[TelescopeOption] = []
	for _move_id in _player_move_container.available_moves.keys():
		var _move : CombatMove = _player_move_container.get_ref(_move_id)
		var opt : TelescopeOption = TelescopeOption.new()

		var info_container : VBoxContainer = VBoxContainer.new()
		var info_label : Label = Label.new()
		info_label.text = _move.description
		var cost_label : Label = Label.new()
		cost_label.text = "Cost: %sSP" % _move.get_sp_cost(_fight) 

		info_container.add_child(info_label)
		info_container.add_child(cost_label)

		opt.info = info_container
		opt.value = _move
		opt.setup_option(_move.display_name)
		options.append(opt)
	return options

func close():
	GlobalLogger.log_i(_PRE_LOG + "Closing Fight UI...")
	hide()	
