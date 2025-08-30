class_name MainPlayer extends Node

var _pre_log : String = "MainPlayer> "


## The current room the player is in
var current_room : int = -1
var previous_room : int = -1
## The rooms the player has previously been to. Does not include the current room
var visited_rooms_uids : Array[int]

var health : float
var money : float
var inventory : Inventory

var dialogue_system : DialogueSystem

signal took_damage(dmg : float)
## Gets called when the player enters a new room
signal entered_new_room
## The player enters a room he's been in before
signal entered_visited_room
## The player enters a room, wether visited or not
signal entered_room
signal dead

## Initializes the player character
func initialize():
	health = 20.0
	money = 2483
	inventory = Inventory.new()

func _ready():
	dialogue_system = GameManager.get_dialogue_system()

func enter_room(room_uid : int):
	Logger.log_i(_pre_log + "Player entering room %s " % room_uid)
	previous_room = current_room
	current_room = room_uid
	if !room_uid in visited_rooms_uids:
		visited_rooms_uids.append(room_uid)
		entered_new_room.emit()
	else:
		entered_visited_room.emit()
	entered_room.emit()

func take_damage(dmg : float = 1.0):
	Logger.log_v(_pre_log + "Player takes %s damage" % dmg)
	health -= dmg
	took_damage.emit(dmg)
	if health <= 0:
		die()

func die():
	dead.emit()
