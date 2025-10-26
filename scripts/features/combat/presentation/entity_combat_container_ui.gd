class_name EntityCombatContainerUI extends Node

@export var entity_name_label : Label
@export var entity_health_label : Label
@export var entity_health_progress_bar : ProgressBar
@export var sequence_container : Control
@export var sp_label : Label

@export var sequenced_move_scene : PackedScene

var _entity : Entity
var current_sequence : Array[CombatMove]
var _fight : Fight

func setup(entity : Entity, fight : Fight):
	_entity = entity
	_fight = fight
	entity_name_label.text = entity.display_name
	if !(entity is MainPlayer):
		sp_label.hide()
	else:
		sp_label.text = "SP: %s" % _entity.current_sp
	entity_health_progress_bar.max_value = _entity.base_health

	_entity.on_take_hit.connect(func(): update_health())
	update_health()

func update_health():
	entity_health_progress_bar.value = _entity.current_health
	entity_health_label.text = "%s/%s" % [_entity.current_health, _entity.base_health]

func _update_sequence_container():
	for c in sequence_container.get_children():
		c.queue_free()
	var i : int = 0
	for _move : CombatMove in current_sequence:
		var sequenced_move_container : SequencedMoveContainer = sequenced_move_scene.instantiate()
		sequenced_move_container.setup(_move, _fight)
		sequenced_move_container.on_remove.connect(func(): remove_from_sequence(i))
		sequence_container.add_child(sequenced_move_container)
		i+=1
	pass

## Visually adds a move from sequence
func add_to_sequence(_move : CombatMove):
	current_sequence.append(_move)
	sp_label.text = "SP: %s" % _entity.current_sp
	_update_sequence_container()

## Visually removes a move from the sequence
func remove_from_sequence(position : int):
	_fight.remove_from_sequence(position)
	current_sequence.remove_at(position)
	sp_label.text = "SP: %s" % _entity.current_sp
	_update_sequence_container()

## Visually sets the sequence
func set_sequence(sequence : Array[CombatMove]):
	current_sequence = sequence
	_update_sequence_container()
