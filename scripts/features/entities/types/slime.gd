extends Entity

func _interact():
	GameManager.get_ui().new_log(Log.new("It doesn't care about you, very slowly proning through the room stopping only when faced with a wall to turn."))
	pass
