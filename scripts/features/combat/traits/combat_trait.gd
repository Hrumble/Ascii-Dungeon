class_name CombatTrait extends Resource
## A combat trait is a trait that an entity (opponent) can possess during combat.
## Whereas the player fights with his equipment, an entity fights with its traits, that, similarly to the equipment reacts to events and actions
## An entity with the "Blood Lust" trait (example) would attack the player on every event if the player is below 10HP for instance.
## You can create modular and creative entities by combining multiple traits.

## Bool that handles checking wether or not this item has already reacted to an event during this sequence.
## Used to avoid looping reactions
var f_has_reacted : bool = false

## Connects this entity to the fight
func connect_to_fight(fight : Fight):
	f_has_reacted = false
	fight.sequencer.action_resolved.connect(on_action_resolved)
	fight.sequencer.reactions_done.connect(_on_reactions_done)
	_connect_to_fight(fight)
	pass

## Connects this entity to the fight. 
## To be overriden
func _connect_to_fight(_fight : Fight):
	pass

## What happens when all the reactions have been resolved
func _on_reactions_done():
	f_has_reacted = false


## What happens when an action gets resolved, used for reactions.
## Will not run if the action was resolved by `self`, or `f_has_reacted` is true.
## calls _react_to_action
func on_action_resolved(action : QueueAction, ctx : FightContext):
	# ensure we don't react to our own action
	if action.source == self:
		return
	# Ensure we don't react multiple times in a single turn
	if f_has_reacted:
		return
	_react_to_action(action, ctx)

## React to an action being resolved, do not forget to set f_has_reacted to `true` if you want to avoid infinite loops.
## To be overriden
func _react_to_action(_action : QueueAction, _ctx : FightContext):
	pass
