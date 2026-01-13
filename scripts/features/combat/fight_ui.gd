class_name FightUI extends CanvasLayer

@export var item_container : HBoxContainer

var _player_manager : PlayerManager

func _ready():
	_player_manager = GameManager.get_player_manager()

func open():
	_display_user_equipment()
	show()

func close():
	hide()
#--------------------------------------------------------------------#
#                             Animations                             #
#--------------------------------------------------------------------#

func _display_user_equipment():
	var window_size : Vector2i = get_viewport().get_window().size
	var equipment : Dictionary[GlobalEnums.EQUIPMENT_SLOTS, Equippable] = _player_manager.player.get_equipped_items()

	var item_width : int = 32
	var item_spacing : int = 24
	var step : int = item_width + item_spacing

	var total_width : int = step * equipment.size() - item_spacing
	var top_left : Vector2 = Vector2(
		window_size.x / 2.0 - total_width / 2.0,
		window_size.y / 2.0 - item_width / 2.0
	)

	var i : int = 0

	for item : Equippable in equipment.values():
		var panel : PanelContainer = PanelContainer.new()
		var texture_rect : TextureRect = TextureRect.new()
		panel.add_child(texture_rect)

		texture_rect.texture = item.texture
		var texture_offset : Vector2 = texture_rect.texture.get_size()/2.0
		texture_rect.pivot_offset = texture_offset
		texture_rect.position = window_size/2.0 - texture_offset
		texture_rect.scale = Vector2.ZERO

		add_child(panel)

		
		var tween = create_tween().set_trans(Tween.TRANS_ELASTIC)

		tween.tween_property(panel, "scale", Vector2(7, 7), .3)

		tween.tween_property(panel, "scale", Vector2(1, 1), .5)
		tween.parallel().tween_property(panel, "position", Vector2(top_left.x + step * i, top_left.y), .5)

		await tween.finished

		i += 1
