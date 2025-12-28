class_name ContextMenu extends Control

@export var text_item_scene : PackedScene
@export var item_container : Control


## Emits when an item is selected with the value given to that item
signal on_pressed(value)
signal on_close

## Adds a selectable text option, when this option is pressed, on_pressed(`value`) will be emitted
func add_text_option(value, text : String, secondary_text : String = ""):
	var text_item : ContextMenuTextItem = text_item_scene.instantiate()
	text_item.setup(text, secondary_text)
	text_item.on_pressed.connect(func(): _on_item_pressed(value))

	item_container.add_child(text_item)

func _input(event):
	## If user clicks or interacts with anywhere that isn't that context menu, hide it
	if event is InputEventMouseButton:
		if event.pressed && not get_global_rect().has_point(event.position):
			close()
			

func _on_item_pressed(value):
	print(value)
	on_pressed.emit(value)
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
