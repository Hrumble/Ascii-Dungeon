class_name ContextMenu extends Control

@export var control_item_scene : PackedScene
@export var item_container : Control


## Emits when an item is selected with the value given to that item
signal on_pressed(value)
signal on_close

## Adds a selectable text option, when this option is pressed, on_pressed(`value`) will be emitted
## If you do not want to rely on `on_pressed`, you can directly set `callback`, which will be called when the item is pressed
func add_text_item(value, text : String, callback = null):
	var control_item : ContextMenuControlItem = control_item_scene.instantiate()
	var label : Label = Label.new()
	label.theme_type_variation = "SmallLabel"
	label.text = text

	control_item.setup(label)
	control_item.on_pressed.connect(func(): _on_item_pressed(value, callback))

	item_container.add_child(control_item)

## Adds a selectable control item, when this option is pressed, on_pressed(`value`) will be emitted
## If you do not want to rely on `on_pressed`, you can directly set `callback`, which will be called when the item is pressed
func add_control_item(value, control : Control, callback):
	var control_item : ContextMenuControlItem = control_item_scene.instantiate()
	control_item.setup(control)
	control_item.on_pressed.connect(func(): _on_item_pressed(value, callback))

	item_container.add_child(control_item)

## Adds a separator, cannot be interacted with
func add_separator():
	item_container.add_child(HSeparator.new())

func _input(event):

	## If user clicks or interacts with anywhere that isn't that context menu, hide it
	if event is InputEventMouseButton:
		if event.pressed && not get_global_rect().has_point(event.position):
			close()
			

func _on_item_pressed(value, callback):
	on_pressed.emit(value)
	if callback != null:
		callback.call()
	close()

## Hides the context menu
func close():
	hide()
	on_close.emit()
	queue_free()

## Empties the context menu of all its previous items
func clear():
	for c in item_container.get_children():
		c.queue_free()
