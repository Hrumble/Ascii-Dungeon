class_name RoomVisionUI extends Control

@export var entities_container : Control
@export var room_pos_label : Label

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
		var label : RichTextLabel = _get_entity_label(entity)
		entities_container.add_child(label)


func _clear_entities():
	for c in entities_container.get_children():
		c.queue_free()


## Creates and returns the appropriate [RichTextLabel] for a provided entity
func _get_entity_label(entity : Entity) -> RichTextLabel:
	var label : RichTextLabel = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	if entity.is_dead:
		label.text = "[s]%s[/s]" % entity.display_name
		label.modulate = Color(255, 255, 255, 0.6)
	else:
		label.text = entity.display_name

	return label
