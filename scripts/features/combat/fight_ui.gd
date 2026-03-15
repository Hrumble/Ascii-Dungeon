class_name FightUI extends CanvasLayer

@export var item_container : Control
@export var equipment_ui_scene : PackedScene
@export var enemy_health_bar : TextureProgressBar
@export var player_health_bar : TextureProgressBar
@export var step_label : Label
@export var turn_count_label : Label

var _player_manager : PlayerManager
var _current_fight : Fight
var object_dict : Dictionary[Object, FightEquipmentUI] = {}
var ready_for_next_turn : bool = false

#--------------------------------------------------------------------#
#                               Icons                                #
#--------------------------------------------------------------------#
var heal_icon : Texture2D = preload("res://resources/tiles/icons/heal_icon.png")
var damage_icon : Texture2D = preload("res://resources/tiles/icons/damage_icon.png")

const _PRE_LOG : String = "FightUI> "
const FIGHT_SPEED : float = 3

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
	_current_fight.sequencer.sequence_finished.connect(_on_sequence_finished)
	_current_fight.running_step.connect(_on_run_step)

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

## Returns the control node assigned to the given object if it exists
func get_control(object : Object) -> FightEquipmentUI:
	var ctrl : FightEquipmentUI = object_dict.get(object)
	if ctrl == null:
		GlobalLogger.log_e(_PRE_LOG + "There is no control assigned to object %s" % object)
		return null
	return ctrl

#--------------------------------------------------------------------#
#                          Action Handlers                           #
#--------------------------------------------------------------------#

## When a new step is begun
func _on_run_step(id : String):
	step_label.text = "Step: %s" % id
	turn_count_label.text = "Turn: %s" % _current_fight.turn_count

func _on_sequence_finished():
	for ctrl : FightEquipmentUI in object_dict.values():
		await ctrl.reset(.2 / FIGHT_SPEED)
	_current_fight.sequencer.ready_for_next.emit()

func _on_action_resolved(action : QueueAction, _ctx : FightContext):
	# Play animations or whatever
	# Ensure each function has the same name of the action, like the [Fight]
	if (action.source is Equippable):
		await callv(action.action, [action])
	else:
		await _display_enemy_action(action, _ctx)

	_update_health_bars()
	_current_fight.sequencer.ready_for_next.emit()
	pass

## Displays an action which has source not set to an Equippable object
func _display_enemy_action(action : QueueAction, _ctx : FightContext):
	var label : Label = Label.new()
	# label.size = Vector2(100, 0)
	label.text = action.action
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	label.pivot_offset_ratio = Vector2(.5, .5)
	label.scale = Vector2(4, 4)

	add_child(label)

	await UIAnimations.slide_from_top(label, .5 / FIGHT_SPEED, get_viewport().get_visible_rect().size/2 - Vector2(label.size.x/2, 128))
	await UIAnimations.pop_out(label, .5 / FIGHT_SPEED)
	label.queue_free()

#--------------------------------------------------------------------#
#                              Actions                               #
#--------------------------------------------------------------------#

## Action called is "damage"
func damage(action : QueueAction):
	var control : FightEquipmentUI = get_control(action.source)
	if control == null:
		return

	await control.step_up(.2 / FIGHT_SPEED)
	await control.shake_and_display_text(str(action.parameters["amount"]), 0.5 / FIGHT_SPEED, 1 * FIGHT_SPEED, damage_icon)
	await control.reset(.2 / FIGHT_SPEED)

## action called is "heal"
func heal(action : QueueAction):
	var control : FightEquipmentUI = get_control(action.source)
	if control == null:
		return

	await control.step_up(.2 / FIGHT_SPEED)
	await control.shake_and_display_text(str(action.parameters["amount"]), .5 / FIGHT_SPEED, 1 * FIGHT_SPEED, heal_icon)
	await control.reset(.2 / FIGHT_SPEED)

#--------------------------------------------------------------------#
#                             Animations                             #
#--------------------------------------------------------------------#


func _display_user_equipment():
	var window_size : Vector2i = get_viewport().get_window().size
	var equipment : Dictionary[GlobalEnums.EQUIPMENT_SLOTS, Equippable] = _player_manager.player.get_equipped_items()

	var item_width : int = 64
	var item_spacing : int = 32
	var step : int = item_width + item_spacing

	var total_width : int = step * (equipment.size() - 1)
	var center_left : Vector2 = Vector2(
		window_size.x / 2.0 - total_width/2.0,
		window_size.y / 2.0
	)

	var i : int = 0

	for item : Equippable in equipment.values():
		var equipment_ui : FightEquipmentUI = equipment_ui_scene.instantiate()

		equipment_ui.set_texture(item.texture)
		equipment_ui.pivot_offset_ratio = Vector2(.5, .5)
		equipment_ui.position = window_size/2.0
		equipment_ui.scale = Vector2.ZERO

		item_container.add_child(equipment_ui)
		object_dict[item] = equipment_ui

		
		var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_speed_scale(3 * FIGHT_SPEED)

		tween.tween_property(equipment_ui, "scale", equipment_ui.scale + Vector2(7, 7), .3 / FIGHT_SPEED)

		tween.tween_property(equipment_ui, "scale", Vector2(2, 2), .5 / FIGHT_SPEED)
		tween.parallel().tween_property(equipment_ui, "position", Vector2(center_left.x + step * i, center_left.y), .5 / FIGHT_SPEED)
		equipment_ui.origin_position = equipment_ui.position

		await tween.finished
		i += 1
