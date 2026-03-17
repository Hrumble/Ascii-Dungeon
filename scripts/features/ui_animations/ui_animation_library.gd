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

## Pops items, then places them inline, centered by `final_center_position`
## this function will also call `show()` on each control node, so they are safe to `hide()`
func line_up(ctrl_nodes : Array, time, final_center_position : Vector2, item_width : int = 64, item_spacing : int = 32):
	## Still awaits the given time if the size is 0
	if ctrl_nodes.size() <= 0:
		await get_tree().create_timer(time).timeout
		return

	var step : int = item_width + item_spacing
	var node_n : int = ctrl_nodes.size()

	var total_width : int = step * (node_n - 1)
	var center_left : Vector2 = Vector2(
		final_center_position.x  - total_width/2.0,
		final_center_position.y
	)

	var i : int = 0

	var op_time : float = time * .5
	for node : Control in ctrl_nodes:
		node.show()
		var f_scale : Vector2 = node.scale
		node.pivot_offset_ratio = Vector2(.5, .5)
		node.position = final_center_position
		node.scale = Vector2.ZERO
		
		var t : Tween = _get_tween()

		t.tween_property(node, "scale", node.scale + Vector2(7, 7), op_time)

		t.tween_property(node, "scale", f_scale, op_time)
		t.parallel().tween_property(node, "position", Vector2(center_left.x + step * i, center_left.y), op_time)
		if (node is FightEquipmentUI):
			node.origin_position = node.position

		await t.finished
		i += 1

# ## Pop items to `final_center_position` from center, then shoves the items as new ones appear
# func line_up_shove(ctrl_nodes : Array, time, final_center_position : Vector2, item_width : int = 64, item_spacing : int = 32):
# 	## Still awaits the given time if the size is 0
# 	if ctrl_nodes.size() <= 0:
# 		await get_tree().create_timer(time).timeout
# 		return
#
# 	var step : int = item_width + item_spacing
# 	var node_n : int = ctrl_nodes.size()
#
# 	var total_width : int = step * (node_n - 1)
# 	var center_left : Vector2 = Vector2(
# 		final_center_position.x  - total_width/2.0,
# 		final_center_position.y
# 	)
#
# 	var op_time : float = (time/node_n) / 2
# 	var i : int = 0
# 	for node : Control in ctrl_nodes:
# 		await pop_in(node, op_time, final_center_position)
# 		await displace(node, op_time, Vector2(center_left.x + step * i, center_left.y), node.scale)
