class_name Equippable extends Item

@export var slots : Array

signal on_equipped
signal on_unequipped

## Connects this item to the corresponding actions for ongoing fight
func connect_to_fight(fight : Fight):
	_connect_to_fight(fight)

func _connect_to_fight(fight : Fight):
	pass

func _get_context_menu(_context_menu : ContextMenu):
	_context_menu.add_text_item("", "Equip", func(): GameManager.get_player_manager().player.equip_item(self))
