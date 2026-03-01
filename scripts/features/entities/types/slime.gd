extends Entity

func _interact():
	GameManager.get_ui().new_log(Log.new("It doesn't care about you, very slowly proning through the room stopping only when faced with a wall to turn."))
	pass

# func _connect_to_fight(_fight : Fight):
# 	_fight.on_run_attacks.connect(_on_run_attacks)
#
# func _on_run_attacks(ctx : FightContext):
# 	ctx.add_to_action_queue(QueueAction.new(self, "damage", {"target": ctx.player_manager.player, "amount": 5}))
