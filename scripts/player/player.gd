class_name MainPlayer extends Node

var _pre_log : String = "MainPlayer> "


## The current room the player is in
var current_room : int
var previous_room : int
## The rooms the player has previously been to. Does not include the current room
var visited_rooms_uids : Array[int]

var health : float
var money : int
var inventory : Inventory

var dialogue_system : DialogueSystem

signal took_damage(dmg : float)
## Gets called when the player enters a new room
signal entered_new_room
signal dead

## Initializes the player character
func initialize():
	health = 20.0
	money = 2483
	inventory = Inventory.new()

func _ready():
	dialogue_system = GameManager.get_dialogue_system()

func enter_room(room_uid : int):
	visited_rooms_uids.append(room_uid)
	previous_room = current_room
	current_room = room_uid
	entered_new_room.emit()


func take_damage(dmg : float = 1.0):
	Logger.log_v(_pre_log + "Player takes %s damage" % dmg)
	health -= dmg
	took_damage.emit(dmg)
	if health <= 0:
		die()

func die():
	dead.emit()
