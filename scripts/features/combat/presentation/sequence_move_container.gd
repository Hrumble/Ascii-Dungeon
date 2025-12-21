class_name SequencedMoveContainer extends Control

@export var move_label : Label
@export var cost_label : Label
@export var remove_button : Button

var move : CombatMove
signal on_remove

func setup(_move : CombatMove, fight : Fight):
	move = _move
	move_label.text = move.display_name
	cost_label.text = "-%sSP" % move.get_sp_cost(fight)
	remove_button.pressed.connect(func(): on_remove.emit())
	

## Lights up the node, only visual for animations
func light_up(light : bool=true):
	if light:
		modulate = Color(0.6, 0.6, 0)
	else:
		modulate = Color(1, 1, 1)
	pass

## Greys out the node, for visual animations
func grey_out(grey : bool = true):
	if grey:
		modulate = Color(1, 1, 1, 0.5)
	else:
		modulate = Color(1, 1, 1, 1)

