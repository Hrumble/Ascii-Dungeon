class_name Consummable extends Item

## Return the context menu of this item, e.g. the menu that should show up on right click. To be overriden
func _get_context_menu(_context_menu : ContextMenu):
	_context_menu.add_text_item("", "Consume")
	pass
