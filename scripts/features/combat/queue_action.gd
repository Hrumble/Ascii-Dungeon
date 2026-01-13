class_name QueueAction

var source : Object
var target : Object
var parameter : String
var amount
var modifier : GlobalEnums.MODIFIERS
## What the value of parameter was before the action being resolved, you must call `resolve` first, otherwise this stays null
var before = null
## What the value is like after the action being resolved, you must call `resolve` first, otherwise this stays null
var after = null

func _init(_source : Object, _target : Object, _parameter : String, _amount, _modifier : GlobalEnums.MODIFIERS):
	source = _source
	target = _target
	parameter = _parameter
	amount = _amount
	modifier = _modifier

## This function resolves the action, i.e. executes it on the target, if the provided parameter does not exist, prints an error. Do not call this function before calling `resolve`,
## as otherwise, the parameter will be set to null
## `resolve` handles doing the calculations
func apply():
	if target.get(parameter) == null:
		GlobalLogger.log_e("QueuedAction> Attempted to set parameter %s of target %s, but it does not exist" % [parameter, target])
		return
	target.set(parameter, after)

## Resolves this action, sets the values `before`, and `after`
func resolve():
	if target.get(parameter) == null:
		GlobalLogger.log_e("QueuedAction> Attempted to set parameter %s of target %s, but it does not exist" % [parameter, target])
		return
	
	before = target.get(parameter)
	match modifier:
		GlobalEnums.MODIFIERS.ADD:
			after = before + amount
		GlobalEnums.MODIFIERS.SUB:
			after = before - amount
		GlobalEnums.MODIFIERS.MULTI:
			after = before * amount
		GlobalEnums.MODIFIERS.SET:
			after = amount
