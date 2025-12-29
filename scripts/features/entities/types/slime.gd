extends Entity

func _interact():
	GameManager.get_ui().new_log(Log.new("It doesn't care about you, very slowly proning through the room stopping only when faced with a wall to turn."))
	pass


func _generate_fight_sequence(_fight: Fight) -> Array[CombatMove]:
	var registry : Registry = GameManager.get_registry()
	var move : CombatMove = registry.get_entry_by_id("combat_slime_lunge")

	# Entity fight AI goes here
	return [move, move]
