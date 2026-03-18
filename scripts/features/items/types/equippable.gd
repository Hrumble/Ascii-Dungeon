class_name Equippable extends Item

@export var slots : Array:
	# This whole shenanigan is to map string slots e.g. "HEAD" to the corresponding enum, and be able to assign it
	# Directly from JSON
	set(v):
		var new_arr : Array[GlobalEnums.EQUIPMENT_SLOTS] = []
		for i in v:
			if i is String:
				new_arr.append(Utils.string_to_equipment_slot(i))
			elif i is GlobalEnums.EQUIPMENT_SLOTS:
				new_arr.append(i)
		slots = new_arr
				

signal on_equipped
signal on_unequipped

#--------------------------------------------------------------------#
#                           Item Specific                            #
#--------------------------------------------------------------------#

func _get_context_menu(_context_menu : ContextMenu):
	_context_menu.add_text_item("", "Equip", func(): GameManager.get_player_manager().player.equip_item(self))

#--------------------------------------------------------------------#
#                        Equippable Specific                         #
#--------------------------------------------------------------------#

## Bool that handles checking wether or not this item has already reacted to an event during this sequence.
## Used to avoid looping reactions
var f_has_reacted : bool = false

## Connects this item to the corresponding actions for ongoing fight
func connect_to_fight(fight : Fight):
	f_has_reacted = false
	fight.sequencer.action_resolved.connect(on_action_resolved)
	fight.sequencer.reactions_done.connect(_on_reactions_done)
	_connect_to_fight(fight)

func _connect_to_fight(_fight : Fight):
	pass

## What happens when all the reactions have been resolved
func _on_reactions_done():
	# Reset the has reacted bool to get ready for next action
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
## to be overriden
func _react_to_action(_action : QueueAction, _ctx : FightContext):
	pass

