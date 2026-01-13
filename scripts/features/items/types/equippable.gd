class_name Equippable extends Item

@export var slots : Array:
	# This whole shenanigan is to map string slots e.g. "HEAD" to the corresponding enum, and be able to assign it
	# Directly from JSON
	set(v):
		var new_arr : Array[GlobalEnums.EQUIPMENT_SLOTS] = []
		for i in v:
			if i is String:
				print(Utils.string_to_equipment_slot(i))
				new_arr.append(Utils.string_to_equipment_slot(i))
			elif i is GlobalEnums.EQUIPMENT_SLOTS:
				new_arr.append(i)
		slots = new_arr
				


signal on_equipped
signal on_unequipped

## Connects this item to the corresponding actions for ongoing fight
func connect_to_fight(fight : Fight):
	_connect_to_fight(fight)

func _connect_to_fight(fight : Fight):
	pass

func _get_context_menu(_context_menu : ContextMenu):
	_context_menu.add_text_item("", "Equip", func(): GameManager.get_player_manager().player.equip_item(self))
