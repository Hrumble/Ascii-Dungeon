extends Entity

var _loot : Array
var _opened : bool = false

func _interact():
	if _opened:
		GameManager.get_ui().new_log(Log.new("", "You have already opened that chest."))
		return
	GameManager.get_ui().new_log(Log.new("Opening a chest", "You step forward and open the chest, it reveals it's content to you..."))
	for item : Dictionary in _loot:
		GameManager.get_player_manager().player.add_item_to_inventory(item["item_id"], item["quantity"])
	_opened = true
	pass


func _on_attacked():
	# On attacked logic goes here
	pass

func _on_spawn():
	_loot = get_loot()


func _talk():
	# on talk logic goes here
	pass


func _die():
	# Death logic goes here
	pass
