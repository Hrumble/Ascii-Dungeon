extends Entity

func _interact():
	# On interacted logic goes here
	pass


func _on_attacked():
	# On attacked logic goes here
	pass


func _take_hit(_weapon : Weapon):
	# being hit by weapon `_weapon` logic goes here
	pass


func _on_spawn():
	# on spawn logic goes here
	pass


func _talk():
	# on talk logic goes here
	pass


func _get_weapon() -> String:
	## What weapon to return when a script ask's for this entity's equipped weapon,
	## Returns null by default (same as no weapon)
	return ""


func _die():
	# Death logic goes here
	pass


func _generate_fight_sequence(_fight: Fight) -> Array[CombatMove]:
	# Entity fight AI goes here
	return []


func _get_loot() -> Array:
	# loot generation logic goes here
	return []
