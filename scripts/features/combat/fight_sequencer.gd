class_name FightSequencer extends Node

## This signal **MUST** be emitted by an external resolver (e.g. UI, in our case the `FightUI`)
## If for anyreason this signal is not emitted the sequencer will hang, there is no failsafe.
signal ready_for_next
## An action has just been resolved
signal action_resolved(action : QueueAction, ctx : FightContext)

const _PRE_LOG : String = "FightSequencer> "


## Resolve all actions in the queue one by one, emits `action_resolved` for each
## Will hang between each action until `ready_for_next` is emitted
func resolve_actions(ctx : FightContext):
	for action : QueueAction in ctx.action_queue:
		_resolve_action(ctx, action)
		await ready_for_next
		for reaction : QueueAction in ctx.reaction_queue:
			_resolve_action(ctx, reaction)
			await ready_for_next

		ctx.reaction_queue.clear()

func _resolve_action(ctx : FightContext, action : QueueAction):
	action.resolve(ctx.fight)
	action_resolved.emit(action, ctx)
