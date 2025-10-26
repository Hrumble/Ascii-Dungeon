class_name InventoryUI extends Control

@export var picker_option_scene: PackedScene
@export var item_container: Control
@export var search_bar: LineEdit
@export var inventory_description_detail: InventoryDescriptionUI

var _player: MainPlayer
var is_opened: bool

var _options: Array
var _selected_option: int = 0
var _is_searching: bool = false

signal inventory_closed


func _ready():
	_player = GameManager.get_player_manager().player
	_player.inventory.inventory_modified.connect(_update_ui)
	close()


func _update_ui():
	# No need to update inventory if it's closed
	if !is_opened:
		return
	# Clears previous ui
	for c in item_container.get_children():
		c.queue_free()
	_options.clear()

	for inventory_item: InventoryItem in _player.inventory.get_items():
		var picker_option: PickerOption = picker_option_scene.instantiate()
		picker_option.set_text(
			inventory_item.get_item_reference().display_name,
			"x%s" % inventory_item.item_quantity,
			inventory_item
		)
		item_container.add_child(picker_option)
		_options.append(picker_option)


func _gui_input(event):
	_handle_inventory_input(event)


## Handles user input on the inventory tab (will later have an equipment tab or else)
func _handle_inventory_input(event: InputEvent):
	if event.is_action_pressed("ui_previous"):
		_select_option(_selected_option - 1)
	elif event.is_action_pressed("ui_next"):
		_select_option(_selected_option + 1)
	elif event.is_action_pressed("ui_end"):
		close()

	# Trigger search mode
	elif event.is_action_pressed("ui_search"):
		await get_tree().process_frame
		search_bar.grab_focus()
		_is_searching = true
	elif event.is_action_pressed("ui_confirm") and _is_searching:
		search_bar.release_focus()
		_is_searching = false


## Selects option n `index`, looping back at 0 when going over n of options
func _select_option(index: int):
	# Ensures it stays between 0 and n of options
	_options[_selected_option].unselect()
	_selected_option = index % _options.size()
	var selected_option: PickerOption = _options[_selected_option]
	selected_option.select()
	var item_ref: Item = (selected_option.value as InventoryItem).get_item_reference() as Item
	inventory_description_detail.set_text(item_ref.display_name, item_ref.description)


## Opens the inventory
func open():
	is_opened = true
	## Ensures the UI is up to date
	_update_ui()
	show()
	await get_tree().process_frame
	focus_mode = Control.FOCUS_ALL
	grab_focus()
	_select_option(_selected_option)


## Closes the inventory
func close():
	is_opened = false
	hide()
	inventory_closed.emit()
