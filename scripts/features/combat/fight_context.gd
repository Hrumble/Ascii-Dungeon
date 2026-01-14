class_name FightContext extends Node

## The current instantiated enemy
var enemy : Entity = null
## The current player
var player_manager : PlayerManager = null
## The intent of the enemy on this turn
var enemy_intent : FightIntent = null
## The move of the enemy on this turn
var enemy_move : FightMove = null
## Wether or not the player blocks
var block_success : bool = false
## The current step in which we are in
var step : int = 0
## The current fight going on
var fight : Fight
## The queue of actions, gets reset on each event!
## an action calls one of the methods inside the [Fight] object directly, an example:
## {"action": "damage", "source": self, "parameters" [ctx.opponent, 10]}
var action_queue : Array[QueueAction]
## Arbitrary custom fight data
var flags : Dictionary = {}

func add_to_action_queue(action : QueueAction):
	GlobalLogger.log_i("FightContext> Action added to queue: %s" % action)
	action_queue.append(action)
