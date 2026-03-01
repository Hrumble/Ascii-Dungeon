extends Equippable

@export var damage : float

func _connect_to_fight(_fight : Fight):
	_fight.on_run_attacks.connect(_on_run_attacks)

func _on_run_attacks(ctx : FightContext):
	ctx.add_to_action_queue(
		QueueAction.new(self, "damage", [ctx.enemy, damage])
		)
	pass
