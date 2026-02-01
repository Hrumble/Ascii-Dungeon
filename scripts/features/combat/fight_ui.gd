class_name FightUI extends CanvasLayer

@export var item_container : Control
@export var equipment_ui_scene : PackedScene
@export var enemy_health_bar : TextureProgressBar
@export var player_health_bar : TextureProgressBar

var _player_manager : PlayerManager
var _current_fight : Fight
var object_dict : Dictionary[Object, FightEquipmentUI] = {}
var ready_for_next_turn : bool = false

#--------------------------------------------------------------------#
#                               Icons                                #
#--------------------------------------------------------------------#
var heal_icon : Texture2D = preload("res://resources/tiles/icons/heal_icon.png")

const _PRE_LOG : String = "FightUI> "

func _ready():
	_player_manager = GameManager.get_player_manager()

func _clear():
	for c in item_container.get_children():
		c.queue_free()
	object_dict.clear()

func open():
	_clear()
	_current_fight = GameManager.get_fight_manager().current_fight

	enemy_health_bar.max_value = _current_fight._opponent.base_health
	player_health_bar.max_value = _current_fight._player_manager.player.base_health

	_update_health_bars()
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
#                               Utils                                #
#--------------------------------------------------------------------#

## Updates the values of the health bars
func _update_health_bars():
	enemy_health_bar.value = _current_fight._opponent.current_health
	player_health_bar.value = _current_fight._player_manager.player.current_health

#--------------------------------------------------------------------#
#                          Action Handlers                           #
#--------------------------------------------------------------------#

func _on_action_resolved(action : QueueAction):
	# Play animations or whatever
	# Ensure each function has the same name of the action, like the [Fight]
	await callv(action.action, [action])

	_update_health_bars()
	_current_fight.sequencer.ready_for_next.emit()
	pass

## Action called is "damage"
func damage(action : QueueAction):
	var control : FightEquipmentUI = object_dict.get(action.source)
	if control == null:
		GlobalLogger.log_e(_PRE_LOG + "There is no control assigned to object %s" % action.source)
		return

	await control.step_up().finished

	var tween : Tween = control.shake_and_display_text(str(action.parameters[1]), heal_icon)
	tween.tween_property(control, "modulate:a", .5, .5)

	await tween.finished

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
	var center_left : Vector2 = Vector2(
		window_size.x / 2.0 - total_width / 2.0,
		window_size.y / 2.0
	)

	var i : int = 0

	for item : Equippable in equipment.values():
		var equipment_ui : FightEquipmentUI = equipment_ui_scene.instantiate()

		equipment_ui.set_texture(item.texture)
		equipment_ui.position = window_size/2.0
		equipment_ui.scale = Vector2.ZERO

		item_container.add_child(equipment_ui)
		object_dict[item] = equipment_ui

		
		var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_speed_scale(3)

		tween.tween_property(equipment_ui, "scale", equipment_ui.scale + Vector2(7, 7), .3)

		tween.tween_property(equipment_ui, "scale", Vector2(2, 2), .5)
		tween.parallel().tween_property(equipment_ui, "position", Vector2(center_left.x + step * i, center_left.y), .5)

		await tween.finished

		i += 1

# func _display_user_equipment():
# 	var window_size : Vector2i = get_viewport().get_window().size
# 	var equipment : Dictionary[GlobalEnums.EQUIPMENT_SLOTS, Equippable] = _player_manager.player.get_equipped_items()
#
# 	var item_width : int = 64
# 	var item_spacing : int = 32
# 	var step : int = item_width + item_spacing
#
# 	var total_width : int = step * equipment.size() - item_spacing
# 	var top_left : Vector2 = Vector2(
# 		window_size.x / 2.0 - total_width / 2.0,
# 		window_size.y / 2.0 - item_width / 2.0
# 	)
#
# 	var i : int = 0
#
# 	for item : Equippable in equipment.values():
# 		var texture_rect : TextureRect = TextureRect.new()
#
# 		texture_rect.texture = item.texture
# 		var texture_offset : Vector2 = texture_rect.texture.get_size()/2.0
# 		texture_rect.pivot_offset = texture_offset
# 		texture_rect.position = window_size/2.0 - texture_offset
# 		texture_rect.scale = Vector2.ZERO
#
# 		item_container.add_child(texture_rect)
# 		object_dict[item] = texture_rect
#
# 		
# 		var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_speed_scale(3)
#
# 		tween.tween_property(texture_rect, "scale", Vector2(7, 7), .3)
#
# 		tween.tween_property(texture_rect, "scale", Vector2(2, 2), .5)
# 		tween.parallel().tween_property(texture_rect, "position", Vector2(top_left.x + step * i, top_left.y), .5)
#
# 		await tween.finished
#
# 		i += 1

func _equipment_reset(tween : Tween, control : Control, time : float = .2):
	tween.tween_property(control, "position", control.position, time)
	tween.tween_property(control, "scale", control.scale, time)

## Puts an equipment piece up to show its the one being used right now
func _equipment_activate(control : Control):
	var tween : Tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(control, "position", control.position - Vector2(0, 32), .5)
	tween.parallel().tween_property(control, "scale", control.scale + Vector2(1, 1), .5)

	await tween.finished

	# tween.tween_property(ctrl, "position", ctrl.position, .5)
	# tween.parallel().tween_property(ctrl, "scale", Vector2(2, 2), .5)
	#
	# await tween.finished

## Little effect to show equipment being used, to pair with damage numbers or something
## Returns the tween to be able to parallel it with another animation
func _equipment_interact(control : Control) -> Tween:
	var tween : Tween = create_tween().set_trans(Tween.TRANS_ELASTIC)

	tween.tween_property(control, "scale", control.scale - Vector2(1, 1), .2)
	return tween
