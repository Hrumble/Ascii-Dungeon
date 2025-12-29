extends Entity

func _interact():
	GameManager.get_dialogue_manager().start_random_dialogue("lone_merchant")
