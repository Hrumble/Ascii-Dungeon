extends Equippable


func _connect_to_fight(fight: Fight):
	fight.on_enemy_declared_intent.connect(_on_enemy_intent)

func _on_enemy_intent(ctx: FightContext):
	var amnt : float = 1
	if ctx.enemy_intent.displayed_intent == GlobalEnums.FIGHT_INTENTS.ATTACK:
		amnt = 5

	ctx.add_to_action_queue(QueueAction.new(
			self, 
			"heal",
			[ctx.player_manager.player, amnt]	
		))
