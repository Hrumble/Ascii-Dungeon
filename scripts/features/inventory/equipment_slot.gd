class_name EquipmentSlotUI extends ItemSlotUI

@export var slot : String = "HEAD"
@export var empty_slot_texture : Texture2D

signal on_unequip_pressed

func set_item(item_id : String):
	super.set_item(item_id)
	texture_rect.modulate = Color(1, 1, 1)

func remove_item():
	item = null
	texture_rect.texture = empty_slot_texture
	texture_rect.modulate = Color(1, 1, 1, .3)

func set_context_menu(_context_menu : ContextMenu):
	pass
