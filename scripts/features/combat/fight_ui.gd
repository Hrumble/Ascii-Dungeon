class_name FightUI extends CanvasLayer

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
	var i : int = 0
	for item : Equippable in _player_manager.player.get_equipped_items().values():
		var texture_rect : TextureRect = TextureRect.new()

		texture_rect.texture = item.texture
		texture_rect.pivot_offset = texture_rect.texture.get_size()/2
		texture_rect.scale = Vector2(0, 0)
		texture_rect.position = Utils.get_centered_pos(texture_rect, Vector2(window_size.x/2, window_size.y/2))

		var name_label : Label = Label.new()

		name_label.text = item.display_name
		name_label.position = Utils.get_centered_pos(name_label, Vector2(window_size.x /2, window_size.y))

		add_child(texture_rect)
		add_child(name_label)

		var tween : Tween = create_tween()
		var text_tween : Tween = create_tween()

		tween.set_trans(Tween.TRANS_ELASTIC)
		tween.set_ease(Tween.EASE_IN_OUT)

		text_tween.set_trans(Tween.TRANS_ELASTIC)
		text_tween.set_ease(Tween.EASE_IN_OUT)

		tween.tween_property(texture_rect, "scale", Vector2(1, 1), 5)
		text_tween.tween_property(name_label, "position", Utils.get_centered_pos(name_label, Vector2(window_size.x/2, window_size.y/2 + 48)), 5)

		tween.tween_property(texture_rect, "position", Utils.get_centered_pos(texture_rect, Vector2(32 + 48 * i, 32)), 1.5)
		text_tween.tween_property(name_label, "modulate", Color(1, 1, 1, 0), 1.5)

		await tween.finished
		i += 1
