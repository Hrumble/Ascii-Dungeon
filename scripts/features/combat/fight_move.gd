class_name FightMove extends Node

## Execute this fight move
func execute(context : FightContext):
	_execute(context)

## Execute this move, to be overriden
func _execute(_context : FightContext):
	pass
