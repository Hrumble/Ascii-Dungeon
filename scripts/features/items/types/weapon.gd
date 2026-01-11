class_name Weapon extends Equippable

@export var damage : float

func _init():
	slots = [GlobalEnums.EQUIPMENT_SLOTS.R_HAND]
