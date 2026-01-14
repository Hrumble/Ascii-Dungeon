class_name FightSequencer extends Node

## This signal **MUST** be emitted by an external resolver (e.g. UI, in our case the `FightUI`)
## If for anyreason this signal is not emitted the sequencer will hang, there is no failsafe.
signal ready_for_next
signal action_resolved(action : QueueAction)

const _PRE_LOG : String = "FightSequencer> "


func resolve_actions(ctx : FightContext):
	for action : QueueAction in ctx.action_queue:
		await _resolve_action(ctx.fight, action)

func _resolve_action(fight : Fight, action : QueueAction):
	action.resolve(fight)
	action_resolved.emit(action)
	await ready_for_next
