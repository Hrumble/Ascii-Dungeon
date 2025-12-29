class_name RoomVisionUI extends Control

@export_category("Local")
@export var entities_container : Control
@export var room_pos_label : Label
@export var text_item_scene : PackedScene

var _player_manager : PlayerManager

func _ready():
	_player_manager = GameManager.get_player_manager()

	_player_manager.entered_room.connect(_on_player_enter_room)


func _on_player_enter_room(room_pos : Vector2i):
	var room : Room = _player_manager.current_room
	room.room_changed.connect(func(): _update_room_entities(room_pos))
	_update_room_entities(room.position)
	pass

## Updates the container with all the room entities
func _update_room_entities(room_pos : Vector2i):
	_clear_entities()
	room_pos_label.text = "Room (%s, %s)" % [room_pos.x, room_pos.y]

	for entity in _player_manager.current_room.instantiated_entities:
		var control : Control = _get_entity_label(entity)
		entities_container.add_child(control)

func _clear_entities():
	for c in entities_container.get_children():
		c.queue_free()

## Creates and returns the appropriate [RichTextLabel] for a provided entity
func _get_entity_label(entity : Entity) -> Control:
	var item : ContextMenuControlItem = text_item_scene.instantiate()
	var label : RichTextLabel = RichTextLabel.new()
	label.fit_content = true

	if entity.is_dead:
		label.text = "[s]%s[/s]" % entity.display_name
		label.modulate = Color(1, 1, 1, .5)
	else:
		label.text = entity.display_name
	
	item.on_hover_input.connect(func(i): _on_entity_input(i, entity))
	item.setup(label)

	return item

## An input is recorded when the player is hovering one of the entities
func _on_entity_input(event, entity : Entity):
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_RIGHT:
			_open_context_menu(entity)


## Opens a context menu when an entity is right clicked
func _open_context_menu(entity : Entity):
	var context_menu : ContextMenu = GameManager.get_ui().get_new_context_menu()
	context_menu.add_text_item("interact", "Interact")
	context_menu.add_text_item("on_attacked", "Attack")

	context_menu.on_pressed.connect(func(v) : _on_entity_option_pressed(v, entity))

func _on_entity_option_pressed(opt, entity : Entity):
	entity.call(opt)
