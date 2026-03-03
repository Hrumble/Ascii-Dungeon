class_name FightIntent
## An intent for an enemy, the `displayed` intent is what the enemy shows he will do
## The `true_intent` is what the enemy will truly do, this is useful in case you want an enemy to "lie"

## What the enemy will do
var true_intent : GlobalEnums.FIGHT_INTENTS
## What the enemy appears to want to do
var displayed_intent : GlobalEnums.FIGHT_INTENTS

func _init(_true : GlobalEnums.FIGHT_INTENTS, _displayed : GlobalEnums.FIGHT_INTENTS):
	true_intent = _true
	displayed_intent = _displayed

func _to_string() -> String:
	return "Intent(true: %s, displayed: %s)" % [true_intent, displayed_intent]
