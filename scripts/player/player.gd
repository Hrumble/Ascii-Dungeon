class_name MainPlayer extends Node

var _pre_log : String = "MainPlayer> "

var health : float
var money : int
var inventory : Inventory

var dialogue_system : DialogueSystem

signal took_damage(dmg : float)
signal dead

## Initializes the player character
func initialize():
	health = 20.0
	money = 2483
	inventory = Inventory.new()

func _ready():
	dialogue_system = GameManager.get_dialogue_system()
	# dialogue_system.start_dialogue_by_name("guidance_spirit", "intro")


func take_damage(dmg : float = 1.0):
	Logger.log_v(_pre_log + "Player takes %s damage" % dmg)
	health -= dmg
	took_damage.emit(dmg)
	if health <= 0:
		die()

func die():
	dead.emit()
