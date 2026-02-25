extends Equippable

func _connect_to_fight(fight: Fight):
	fight.on_enemy_declared_intent.connect(_on_enemy_intent)

func _react_to_action(action : QueueAction, ctx : FightContext):
	if action.action == "damage":
		ctx.add_to_reaction_queue(QueueAction.new(
			self,
			"heal",
			[ctx.player_manager.player, 3]
		))
	f_has_reacted = true

func _on_enemy_intent(ctx: FightContext):
	f_has_reacted = false
	var amnt : float = 1
	if ctx.enemy_intent.displayed_intent == GlobalEnums.FIGHT_INTENTS.ATTACK:
		amnt = 5

	ctx.add_to_action_queue(QueueAction.new(
			self, 
			"damage",
			[ctx.player_manager.player, amnt]	
		))
