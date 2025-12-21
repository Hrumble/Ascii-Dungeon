class_name EntityDieScreenUI extends Control

@export var animation_player : AnimationPlayer
@export var continue_button : Button
@export var entity_name_label : Label

func _ready():
	continue_button.pressed.connect(_on_next_pressed)

func open(entity_name : String):
	entity_name_label.text = entity_name
	show()
	_play_anim()

func _play_anim():
	animation_player.play("DeadTextAnim")

func _on_next_pressed():
	GameManager.get_combat_manager().end_fight()
	pass
