class_name InventorySlotUI extends Control

var inventory_item : InventoryItem
@export var quantity_label : Label

signal on_hover
signal on_hover_end

var is_hovering : bool = false

func set_up(_inventory_item : InventoryItem):
	inventory_item = _inventory_item
	quantity_label.text = str(_inventory_item.item_quantity)

func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var mouse_in : bool = get_global_rect().has_point(mouse_pos)
	if mouse_in and !is_hovering:
		on_hover.emit()
		is_hovering = true
	elif !mouse_in and is_hovering:
		on_hover_end.emit()
		is_hovering = false

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.keycode == MOUSE_BUTTON_LEFT and is_hovering:
				pass
				
