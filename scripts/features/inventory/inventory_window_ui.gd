extends Control

@export_subgroup("Packed Scenes")
@export var item_slot_scene : PackedScene
@export var equipment_slot_scene : PackedScene
@export_subgroup("Containers")
@export var inventory_container : GridContainer
@export var equipment_slots_container : Control
@export_subgroup("Equipment Textures")
@export var head : Texture2D = null
@export var chest : Texture2D = null
@export var hand : Texture2D = null
@export var legs : Texture2D = null
@export var feet : Texture2D = null
@export var finger : Texture2D = null
@export var belt : Texture2D = null


var equipment_textures : Dictionary
var _player_inventory : Inventory
var _player : MainPlayer
## Maps `item_id` -> [InventorySlotUI]
var _displayed_slots : Dictionary
## Maps `item_slot` -> [EquipmentSlotUI]
var _displayed_equipment : Dictionary
var _needs_update : bool = true
var _needs_equipment_update : bool = true

var _closed : bool = false

const _PRE_LOG = "InventoryWindow> "

func _ready():
	_player = GameManager.get_player_manager().player
	_player_inventory = _player.inventory

	_player_inventory.inventory_modified.connect(_update_inventory)
	_player_inventory.count_updated.connect(_update_count)
	_player.equipment_modified.connect(_update_equipment)

	_update_inventory()
	equipment_textures = {
		"HEAD": head,
		"CHEST": chest,
		"LEGS": legs,
		"FEET": feet,
		"R_HAND": hand,
		"L_HAND": hand,
		"BELT": belt,
		"R_FINGER_0": finger, #6
		"R_FINGER_1": finger, #7
		"L_FINGER_0": finger, #8
		"L_FINGER_1": finger, #9
	}
	pass

## Updates the displayed equipment
func _update_equipment():
	if _closed:
		_needs_equipment_update = true
		return

	for slot in _player.equipment.keys():
		var slot_ui : EquipmentSlotUI = _displayed_equipment.get(slot)
		if slot_ui == null:
			slot_ui = equipment_slot_scene.instantiate()
			slot_ui.empty_slot_texture = equipment_textures[slot]
			equipment_slots_container.add_child(slot_ui)
			_displayed_equipment[slot] = slot_ui

		if _player.equipment[slot] != null: 
			slot_ui.set_item(_player.equipment[slot].item_id)
			slot_ui.on_right_click.connect(func(): _on_equipment_right_click(slot))
		else:
			slot_ui.remove_item()

	_needs_equipment_update = false

## Update the inventory slots
func _update_inventory():
	# If the inventory is closed, then we just mark it as needs update, we'll update it on next open
	if _closed:
		_needs_update = true
		return 

	for inventory_item : InventoryItem in _player_inventory.get_items():
		# If we already have a slot for this item, don't instantiate a new one
		var slot = _displayed_slots.get(inventory_item.item_id)
		var _already_exists : bool = slot != null

		if !_already_exists:
			slot = item_slot_scene.instantiate()

		slot.set_item(inventory_item.item_id)
		slot.set_count(inventory_item.item_quantity)

		(slot as InventorySlotUI).on_right_click.connect(func(): _on_item_right_click(inventory_item.item_id))

		if !_already_exists:
			_displayed_slots[inventory_item.item_id] = slot
			inventory_container.add_child(slot)

	_needs_update = false
	_remove_unused_slots()

## When the user right clicks on an equipment slot
func _on_equipment_right_click(slot : String):
	var equipment_slot : EquipmentSlotUI = _displayed_equipment.get(slot)
	if equipment_slot == null:
		return

	var context_menu : ContextMenu = GameManager.get_ui().get_new_context_menu()
	context_menu.add_text_item("", "Information", func(): GameManager.get_ui().open_item_information(equipment_slot.item))
	context_menu.add_text_item("", "Unequip", func(): _player.unequip_item(slot))
	context_menu.add_separator()
	equipment_slot.set_context_menu(context_menu)


## User rights click on any slot (not equipment)
func _on_item_right_click(item_id : String):
	if !_displayed_slots.has(item_id):
		GlobalLogger.log_e(_PRE_LOG + "A right clicked item doesn't have an assigned slot: %s" % item_id)
		return

	var slot : InventorySlotUI = _displayed_slots[item_id]

	var context_menu : ContextMenu = GameManager.get_ui().get_new_context_menu()
	context_menu.add_text_item("", "Drop", func(): _on_item_dropped(item_id))
	context_menu.add_text_item("", "Information", func(): GameManager.get_ui().open_item_information(slot.item))
	context_menu.add_separator()
	slot.set_context_menu(context_menu)
	

func _on_item_dropped(item_id : String):
	_player.remove_item_from_inventory(item_id)

## Removes every slot that is not present in the player inventory
func _remove_unused_slots():
	for key in _displayed_slots.keys():
		if !_player_inventory.content.has(key):
			(_displayed_slots[key] as InventorySlotUI).queue_free()
			_displayed_slots.erase(key)
		

## Updates the count of slots 
func _update_count(item_id : String, count : int):
	if _closed:
		_needs_update = true
		return

	# We don't need to check if inventory is closed here, as this is an inexpensive operation
	var slot : InventorySlotUI = _displayed_slots.get(item_id)
	if slot == null:
		GlobalLogger.log_e(_PRE_LOG + "No slot matching for item id %s, cannot update count" % item_id)
		return

	slot.set_count(count)

func open():
	_closed = false
	if _needs_update:
		_update_inventory()
	if _needs_equipment_update:
		_update_equipment()

	show()

func close():
	hide()
	_closed = true
