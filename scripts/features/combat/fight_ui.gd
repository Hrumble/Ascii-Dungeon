class_name FightUI extends CanvasLayer

var _player_manager : PlayerManager
var _current_fight : Fight
var object_dict : Dictionary[Object, Control] = {}
var ready_for_next_turn : bool = false
const _PRE_LOG : String = "FightUI> "

func _ready():
	_player_manager = GameManager.get_player_manager()

func open():
	_current_fight = GameManager.get_fight_manager().current_fight
	if _current_fight == null:
		GlobalLogger.log_e(_PRE_LOG + "FightUI has been opened, but there is no ongoing fight")
		close()
		return

	show()
	await _display_user_equipment()
	_current_fight.sequencer.action_resolved.connect(_on_action_resolved)

	_current_fight.start_fight()

func close():
	hide()

#--------------------------------------------------------------------#
#                          Action Handlers                           #
#--------------------------------------------------------------------#

func _on_action_resolved(action : QueueAction):
	## Play animations or whatever
	print("UI running action %s" % action)
	await get_tree().create_timer(1).timeout
	_current_fight.sequencer.ready_for_next.emit()
	pass


#--------------------------------------------------------------------#
#                             Animations                             #
#--------------------------------------------------------------------#

func _display_user_equipment():
	var window_size : Vector2i = get_viewport().get_window().size
	var equipment : Dictionary[GlobalEnums.EQUIPMENT_SLOTS, Equippable] = _player_manager.player.get_equipped_items()

	var item_width : int = 64
	var item_spacing : int = 32
	var step : int = item_width + item_spacing

	var total_width : int = step * equipment.size() - item_spacing
	var top_left : Vector2 = Vector2(
		window_size.x / 2.0 - total_width / 2.0,
		window_size.y / 2.0 - item_width / 2.0
	)

	var i : int = 0

	for item : Equippable in equipment.values():
		var texture_rect : TextureRect = TextureRect.new()

		texture_rect.texture = item.texture
		var texture_offset : Vector2 = texture_rect.texture.get_size()/2.0
		texture_rect.pivot_offset = texture_offset
		texture_rect.position = window_size/2.0 - texture_offset
		texture_rect.scale = Vector2.ZERO

		add_child(texture_rect)
		object_dict[item] = texture_rect

		
		var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_speed_scale(3)

		tween.tween_property(texture_rect, "scale", Vector2(7, 7), .3)

		tween.tween_property(texture_rect, "scale", Vector2(2, 2), .5)
		tween.parallel().tween_property(texture_rect, "position", Vector2(top_left.x + step * i, top_left.y), .5)

		await tween.finished

		i += 1
