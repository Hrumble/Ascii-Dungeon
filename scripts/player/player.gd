class_name MainPlayer extends Node

const _PRE_LOG : String = "MainPlayer> "


## The current room the player is in
var current_room : Vector2i
var previous_room : Vector2i
## The rooms the player has previously been to. Does not include the current room
var visited_positions : Array[Vector2i]

var player_position : Vector2i

var health : float
var money : float
var inventory : Inventory
var combat_move_container : CombatMoveContainer

## The attributes are properties the player logic is based on
var attributes : Dictionary = {
	MAX_HEALTH = 10.0,
	BASE_ATTACK_DAMAGE = 5.0
}

var equipment : Dictionary = {
	HEAD = null,
	CHEST = null,
	LEGS = null,
	FEET = null,
	HANDS = null,
	BELT = null,
}

var dialogue_system : DialogueManager

signal took_damage(dmg : float)
## Gets called when the player enters a new room
signal entered_new_room(room_pos : Vector2i)
## The player enters a room he's been in before
signal entered_visited_room(room_pos : Vector2i)
## The player enters a room, wether visited or not
signal entered_room(room_pos : Vector2i)
signal dead

## Initializes the player character
func initialize():
	health = 20.0
	money = 2483
	player_position = Vector2i(0, 0)
	# Initializes inventory
	inventory = Inventory.new()
	inventory.add_item("apple", 8)
	inventory.add_item("jar", 2)
	inventory.add_item("spider_leg")

	# Initializes combat_move_container
	combat_move_container = CombatMoveContainer.new()
	combat_move_container.add_move("combat_move")

func _ready():
	dialogue_system = GameManager.get_dialogue_manager()

func enter_room(room_pos : Vector2i):
	Logger.log_i(_PRE_LOG + "Player entering room %s " % room_pos)
	previous_room = current_room
	current_room = room_pos
	if room_pos in visited_positions:
		entered_visited_room.emit(room_pos)
	else:
		visited_positions.append(room_pos)
		entered_new_room.emit(room_pos)
	entered_room.emit(room_pos)

func take_hit(weapon_id : String):
	var weapon : Weapon = GameManager.get_registry().get_entry_by_id(weapon_id)
	if weapon == null:
		Logger.log_e(_PRE_LOG + "Weapon does not exist, not taking damage")
		return
	Logger.log_d(_PRE_LOG + "Player takes hit from: %s" % weapon.display_name)
	health -= weapon.damage
	took_damage.emit(weapon.damage)
	if health <= 0:
		die()

func die():
	dead.emit()
