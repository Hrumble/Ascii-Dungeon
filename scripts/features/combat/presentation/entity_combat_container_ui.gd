class_name EntityCombatContainerUI extends Node

@export var entity_name_label : Label
@export var entity_health_label : Label
@export var entity_health_progress_bar : ProgressBar
@export var sequence_container : Control
@export var sp_label : Label

@export var sequenced_move_scene : PackedScene

var _entity : Entity
var current_sequence : Array[CombatMove]

var current_sequenced_nodes : Array[SequencedMoveContainer]
var current_lit_up_node : SequencedMoveContainer

var _fight : Fight

func setup(entity : Entity, fight : Fight):
	_entity = entity
	_fight = fight

	_fight.step_started.connect(_on_step_started)
	_fight.sequence_done.connect(_on_fight_sequence_done)

	entity_name_label.text = entity.display_name
	if !(entity is MainPlayer):
		sp_label.hide()
		_fight.opponent_sequence_set.connect(_on_opponent_sequence_set)
	else:
		sp_label.text = "SP: %s" % _entity.current_sp
	entity_health_progress_bar.max_value = _entity.base_health

	_entity.on_take_hit.connect(func(_weapon_id : String): update_health())
	update_health()

func _on_fight_sequence_done():
	# Empty the sequence
	set_sequence([])
	pass

func _on_opponent_sequence_set(sequence : Array[CombatMove]):
	set_sequence(sequence)
	pass

func _on_step_started(index : int):
	light_up_node(index)
	pass

func update_health():
	entity_health_progress_bar.value = _entity.current_health
	entity_health_label.text = "%s/%s" % [_entity.current_health, _entity.base_health]

func _update_sequence_container():
	for c in current_sequenced_nodes:
		c.queue_free()
	current_sequenced_nodes.clear()
	var i : int = 0
	for _move : CombatMove in current_sequence:
		var sequenced_move_container : SequencedMoveContainer = sequenced_move_scene.instantiate()
		sequenced_move_container.setup(_move, _fight)
		sequenced_move_container.on_remove.connect(func(): remove_from_sequence(i))
		sequence_container.add_child(sequenced_move_container)
		current_sequenced_nodes.append(sequenced_move_container)
		i+=1
	pass

func light_up_node(index : int):
	if current_lit_up_node != null:
		current_lit_up_node.light_up(false)
		current_lit_up_node = null
	if !index >= current_sequenced_nodes.size():
		current_sequenced_nodes[index].light_up()
		current_lit_up_node = current_sequenced_nodes[index]
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
