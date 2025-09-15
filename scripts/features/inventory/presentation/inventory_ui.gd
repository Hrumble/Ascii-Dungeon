class_name InventoryUI extends Control

@export var inventory_slot_scene : PackedScene
@export var inventory_grid : Control
@export var tooltip_ui : TooltipUI

var _player : MainPlayer
var _ui_slots : Array
var is_opened : bool
signal inventory_closed

func _ready():
	_player = GameManager.get_player_manager().player
	_player.inventory.inventory_modified.connect(_update_ui)
	tooltip_ui.close()
	close()

## Updates the UI of the inventory
func _update_ui():
	## No use updating if the inventory isn't even opened
	if !is_opened:
		return
	# Clears the previous slots
	for slot : InventorySlotUI in _ui_slots:
		slot.queue_free()
	_ui_slots.clear()
	for inventory_item : InventoryItem in _player.inventory.content.values():
		_instantiate_slot(inventory_item)

func _gui_input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if event.keycode == KEY_ESCAPE:
				close()
				inventory_closed.emit()

func _on_slot_hover(inventory_item : InventoryItem):
	var item : Item = inventory_item.get_item()
	var mouse_pos : Vector2 = get_local_mouse_position()
	tooltip_ui.open(item.display_name, item.description, mouse_pos)

func _on_slot_end_hover():
	tooltip_ui.close()

func _instantiate_slot(inventory_item : InventoryItem):
	var slot_ui : InventorySlotUI = inventory_slot_scene.instantiate()
	slot_ui.set_up(inventory_item)
	inventory_grid.add_child(slot_ui)
	_ui_slots.append(slot_ui)
	slot_ui.on_hover.connect(func(): _on_slot_hover(inventory_item))
	slot_ui.on_hover_end.connect(_on_slot_end_hover)

## Opens the inventory
func open():
	is_opened = true
	## Ensures the UI is up to date
	_update_ui()
	show()
	await get_tree().process_frame
	focus_mode = Control.FOCUS_ALL
	grab_focus()

## Closes the inventory
func close():
	is_opened = false
	hide()
