class_name FightContext extends Node

## The current instantiated enemy
var enemy : Entity = null
## The current player
var player_manager : PlayerManager = null
## The intent of the enemy on this turn
var enemy_intent : FightIntent = null
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
## A queue of reactions to an action, when each action in the `action_queue` gets resolved, they emit a signal
## To which equipment can subscribe to react. e.g. `ring of health` : (on damage) -> (health + 5)
var reaction_queue : Array[QueueAction]
## Arbitrary custom fight data
var flags : Dictionary = {}

## Adds an action to `context.action_queue`
func add_to_action_queue(action : QueueAction):
	action_queue.append(action)
	GlobalLogger.log_i("FightContext> Action added to queue: %s" % action)

## Adds a reaction to `context.reaction_queue`
func add_to_reaction_queue(action : QueueAction):
	reaction_queue.append(action)
	GlobalLogger.log_i("FightContext> Reaction added to queue: %s" % action)

## Clears the reaction queue
func clear_reaction_queue():
	reaction_queue.clear()
	GlobalLogger.log_i("FightContext> Reaction queue cleared")
