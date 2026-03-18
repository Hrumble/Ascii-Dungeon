extends CombatTrait

@export var amount : float

func _react_to_action(_action : QueueAction, _ctx : FightContext):
	if _action.action == "damage" && _action.source == _ctx.enemy:
		_ctx.add_to_reaction_queue(QueueAction.new(
			_ctx.enemy,
			"heal",
			{"target": _ctx.enemy, "amount": amount}
		))
		pass
	pass

func _get_name() -> String:
	return "Thorned"
