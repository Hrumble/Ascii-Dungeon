extends Node

#--------------------------------------------------------------------#
#                               Utils                                #
#--------------------------------------------------------------------#

## Returns the tween used throughout the library
func _get_tween() -> Tween:
	return get_tree().create_tween().set_trans(Tween.TRANS_ELASTIC)

#--------------------------------------------------------------------#
#                                Pops                                #
#--------------------------------------------------------------------#

## Pops in the node
func pop_in(ctrl : Control, time : float, final_position : Vector2):
	var t : Tween = _get_tween()
	## Keeps track of the desired final scale
	var f_scale : Vector2 = ctrl.scale

	ctrl.scale = Vector2(0, 0)
	ctrl.position = final_position
	t.tween_property(ctrl, "scale", f_scale, time)
	t.parallel().tween_property(ctrl, "position", final_position, time)

	await t.finished

## Pops out the node, if `reset` is true, the node will be set back to it's default values after the animation is done
func pop_out(ctrl : Control, time : float, reset : bool = false):
	var t : Tween = _get_tween()
	var f_scale : Vector2 = ctrl.scale
	t.tween_property(ctrl, "scale", Vector2(0, 0), time)

	await t.finished
	if reset:
		ctrl.scale = f_scale

#--------------------------------------------------------------------#
#                               Slides                               #
#--------------------------------------------------------------------#

## Slides in
func slide_from_left(ctrl : Control, time : float, final_position : Vector2):
	var t : Tween = _get_tween()
	ctrl.global_position = Vector2(-ctrl.size.x, final_position.y)
	t.tween_property(ctrl, "position", final_position, time)

	await t.finished

## Slides out
func slide_to_left(ctrl : Control, time : float):
	var t : Tween = _get_tween()
	t.tween_property(ctrl, "position", Vector2(-ctrl.size.x, ctrl.position.y), time)

	await t.finished

## Slides in
func slide_from_right(ctrl : Control, time : float, final_position : Vector2):
	var t : Tween = _get_tween()
	ctrl.global_position = Vector2(get_viewport().get_visible_rect().size.x + ctrl.size.x, final_position.y)
	t.tween_property(ctrl, "position", final_position, time)

	await t.finished

## Slides out
func slide_to_right(ctrl : Control, time : float):
	var t : Tween = _get_tween()
	t.tween_property(ctrl, "position", Vector2(get_viewport().get_visible_rect().size.x + ctrl.size.x, ctrl.position.y), time)

	await t.finished

## Slides from the top
func slide_from_top(ctrl : Control, time : float, final_position : Vector2):
	var t : Tween = _get_tween()
	ctrl.position = Vector2(final_position.x, ctrl.size.y)

	t.tween_property(ctrl, "position:y", final_position.y, time)

	await t.finished

## Slides from the bottom
func slide_from_bottom(ctrl : Control, time : float, final_position : Vector2):
	var t : Tween = _get_tween()
	ctrl.position = Vector2(final_position.x, -get_viewport().get_visible_rect().size.y - ctrl.size.y)

	t.tween_property(ctrl, "position:y", final_position.y, time)
	await t.finished

#--------------------------------------------------------------------#
#                                Misc                                #
#--------------------------------------------------------------------#

## Moves and scales the control node, if `reset` is true, the node will be set back to it's default values after the animation is done
func displace(ctrl : Control, time : float, final_position : Vector2, final_scale : Vector2, reset : bool = false):
	var t : Tween = _get_tween()
	var f_scale : Vector2 = ctrl.scale
	var f_pos : Vector2 = ctrl.position
	t.tween_property(ctrl, "scale", final_scale, time)
	t.parallel().tween_property(ctrl, "position", final_position, time)

	await t.finished

	if reset:
		ctrl.scale = f_scale
		ctrl.position = f_pos

#--------------------------------------------------------------------#
#                              Multiple                              #
#--------------------------------------------------------------------#
# Moves multiple control nodes sequentially

func line_up(ctrl_nodes : Array[Control], time, final_center_position : Vector2, item_width : int = 64, item_spacing : int = 32):
	var window_size : Vector2i = get_viewport().get_window().size

	var step : int = item_width + item_spacing

	var total_width : int = step * (ctrl_nodes.size() - 1)
	var center_left : Vector2 = Vector2(
		final_center_position.x  - total_width/2.0,
		final_center_position.y
	)

	var i : int = 0

	for node : Control in ctrl_nodes:
		node.pivot_offset_ratio = Vector2(.5, .5)
		node.position = window_size/2.0
		node.scale = Vector2.ZERO
		
		var t : Tween = _get_tween()

		t.tween_property(node, "scale", node.scale + Vector2(7, 7), time)

		t.tween_property(node, "scale", Vector2(2, 2), time)
		t.parallel().tween_property(node, "position", Vector2(center_left.x + step * i, center_left.y), time)
		node.origin_position = node.position

		await t.finished
		i += 1
