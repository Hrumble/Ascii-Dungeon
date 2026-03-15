extends CombatTrait

@export var amount : float 

func _connect_to_fight(_fight : Fight):
	_fight.on_run_attacks.connect(_on_run_attacks)
	pass

func _on_run_attacks(ctx : FightContext):
	ctx.add_to_action_queue(QueueAction.new(ctx.enemy, "damage", {"target": ctx.player_manager.player, "amount": amount}))
	pass

func _get_name() -> String:
	return "Dumb Hitter"
