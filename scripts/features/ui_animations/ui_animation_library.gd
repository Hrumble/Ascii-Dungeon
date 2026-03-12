extends Node

#--------------------------------------------------------------------#
#                               Utils                                #
#--------------------------------------------------------------------#

func _get_tween() -> Tween:
	return get_tree().create_tween().set_trans(Tween.TRANS_ELASTIC)

#--------------------------------------------------------------------#
#                                Pops                                #
#--------------------------------------------------------------------#

func pop_in(ctrl : Control, time : float, final_position : Vector2):
	var t : Tween = _get_tween()
	## Keeps track of the desired final scale
	var f_scale : Vector2 = ctrl.scale

	ctrl.scale = Vector2(0, 0)
	ctrl.position = final_position
	t.tween_property(ctrl, "scale", f_scale, time)
	t.parallel().tween_property(ctrl, "position", final_position, time)

	await t.finished

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
	ctrl.position = Vector2(-ctrl.size.x, final_position.y)
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
	ctrl.position = Vector2(get_viewport().get_visible_rect().size.x + ctrl.size.x, final_position.y)
	t.tween_property(ctrl, "position", final_position, time)

	await t.finished

## Slides out
func slide_to_right(ctrl : Control, time : float):
	var t : Tween = _get_tween()
	t.tween_property(ctrl, "position", Vector2(get_viewport().get_visible_rect().size.x + ctrl.size.x, ctrl.position.y), time)

	await t.finished

#--------------------------------------------------------------------#
#                                Misc                                #
#--------------------------------------------------------------------#

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
