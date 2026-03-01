extends Equippable

func _react_to_action(action : QueueAction, ctx : FightContext):
	if action.action == "damage" and action.parameters["target"] == ctx.player_manager.player:
		ctx.add_to_reaction_queue(QueueAction.new(
			self,
			"heal",
			{"target": ctx.player_manager.player, "amount": 3}
		))
	f_has_reacted = true
