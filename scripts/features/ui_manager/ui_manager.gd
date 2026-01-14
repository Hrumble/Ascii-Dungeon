class_name UIManager extends Node

var _game_ui_scene : PackedScene = preload("res://scripts/general/game_ui.tscn")
var _fight_ui_scene : PackedScene = preload("res://scripts/features/combat/presentation/fight_ui.tscn")

var game_ui : MainGameUI
var fight_ui : FightUI

func _ready():
	game_ui = _game_ui_scene.instantiate()
	fight_ui = _fight_ui_scene.instantiate()

	add_child(game_ui)
	add_child(fight_ui)

	set_current(UI.GAME_UI)

	GameManager.get_fight_manager().fight_started.connect(func(_f): set_current(UI.FIGHT_UI))
	GameManager.get_fight_manager().fight_ended.connect(func(): set_current(UI.GAME_UI))

## The available UIs
enum UI {
	GAME_UI,
	FIGHT_UI
}

## Sets the current UI to be shown, only a single UI (canvas layer) can be shown at once
## This is a limit I put there myself for absolutely no reason, you're welcome
func set_current(ui : UI):
	_hide_all()
	if (ui == UI.GAME_UI):
		game_ui.open()
	elif (ui == UI.FIGHT_UI):
		fight_ui.open()

func _hide_all():
	game_ui.close()
	fight_ui.close()
