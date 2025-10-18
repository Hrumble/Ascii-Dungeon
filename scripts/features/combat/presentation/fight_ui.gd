class_name FightUI extends Control

@export var map_container : MapContainer
const _PRE_LOG : String = "FightUI> "
var combat_move_container : CombatMoveContainer

func _ready():
	close()

func open():
	Logger.log_i(_PRE_LOG + "Opening Fight UI...")
	combat_move_container = GameManager.get_player_manager().player.combat_move_container
	map_container.generate_map(3)
	show()
	await get_tree().process_frame
	grab_focus()

func _gui_input(event):
	if event.is_action_pressed("ui_accept"):
		var value = await GameManager.get_ui().open_telescope(_get_moves_options())
		await get_tree().process_frame
		grab_focus()
		print("Picked %s" % value)

func _get_moves_options() -> Array[TelescopeOption]:
	var options : Array[TelescopeOption] = []
	for _move_id in combat_move_container.available_moves.keys():
		var _move : CombatMove = combat_move_container.get_ref(_move_id)
		var opt : TelescopeOption = TelescopeOption.new()

		var info : Label = Label.new()
		info.text = _move.description
		info.size_flags_vertical = Control.SIZE_FILL

		opt.info = info
		opt.value = _move
		opt.setup_option(_move.display_name)
		options.append(opt)
	return options

func close():
	Logger.log_i(_PRE_LOG + "Closing Fight UI...")
	hide()	
