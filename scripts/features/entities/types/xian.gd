extends Entity

func _interact():
	GameManager.get_ui().new_log(Log.new("Xian kisses you!", "You're so lucky! shes so pretty and shes kissing you!"))
	pass
