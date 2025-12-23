class_name Spacer extends Control

## Axis is 0 for horizontal, 1 for vertical, 2 for both
func _init(axis : int):
	if axis < 1:
		size_flags_horizontal = Control.SIZE_EXPAND
	if axis <= 1:
		size_flags_vertical = Control.SIZE_EXPAND
	
	
