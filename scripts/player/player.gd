class_name MainPlayer extends Entity

const _PRE_LOG: String = "MainPlayer> "

var _game_ui: MainGameUI
var _registry: Registry

var money: float
var inventory: Inventory

## Do not use, prefer getting the current room from the player manager instead
## This variable is used for entities that are spawned within rooms, this is not the case for the player and therefore will always return null
var current_room: Room = null

## The attributes are properties the player logic is based on
## Not implemented
# var attributes: Dictionary = {MAX_HEALTH = 10.0, BASE_ATTACK_DAMAGE = 5.0}

## It is recommended that this matches `GlobalEnums.EQUIPMENT_SLOTS
var equipment: Dictionary = {
	"HEAD": null,
	"CHEST": null,
	"LEGS": null,
	"FEET": null,
	"R_HAND": null,
	"L_HAND": null,
	"BELT": null,
	"R_FINGER_0": null, #6
	"R_FINGER_1": null, #7
	"L_FINGER_0": null, #8
	"L_FINGER_1": null, #9
}

var dialogue_system: DialogueManager

signal took_damage(dmg: float)
signal dead
signal equipment_modified


func _get_ui():
	if _game_ui == null:
		_game_ui = GameManager.get_ui()
	return _game_ui


## Initializes the player character
func initialize():
	_registry = GameManager.get_registry()

	# Initializes values
	base_health = 20.0
	base_sp = 5
	display_name = "Player"
	money = 2483

	current_health = base_health
	current_sp = base_sp

	# Initializes inventory
	inventory = Inventory.new()
	add_item_to_inventory("apple", 8)
	add_item_to_inventory("meat")
	add_item_to_inventory("ring_of_health")


func _ready():
	dialogue_system = GameManager.get_dialogue_manager()


func add_item_to_inventory(item_id: String, quantity: int = 1):
	_get_ui()
	if !_game_ui == null:
		_game_ui.new_log(
			Log.new(
				(
					"received %sx [color=light_blue]%s[/color]"
					% [quantity, _registry.get_entry_property(item_id, "display_name")]
				),
				GlobalEnums.LogType.GAME_INFO
			)
		)
	inventory.add_item(item_id, quantity)
	pass


func remove_item_from_inventory(item_id: String, quantity: int = 1):
	_get_ui()
	if !_game_ui == null:
		_game_ui.new_log(
			Log.new(
				(
					"removed %sx [color=red]%s[/color]"
					% [quantity, _registry.get_entry_property(item_id, "display_name")]
				),
				GlobalEnums.LogType.GAME_INFO
			)
		)
		inventory.remove_item_quantity(item_id, quantity)


## Connects all equipment of this player to the fight
func connect_to_fight(fight: Fight):
	for key in equipment.keys():
		var item = equipment[key]
		if item != null and item is Equippable:
			(item as Equippable).connect_to_fight(fight)
		else:
			(
				GlobalLogger
				. log_w(
					(
						_PRE_LOG
						+ (
							"attempted to connect equipment on slot %s, but it is either null or not [Equippable]"
							% key
						)
					)
				)
			)


func _take_hit(weapon: Weapon):
	GlobalLogger.log_d(_PRE_LOG + "Player takes hit from: %s" % weapon.display_name)
	current_health -= weapon.damage
	took_damage.emit(weapon.damage)
	if current_health <= 0:
		die()

## Equips an item to its associated slot
func equip_item(item : Equippable):
	if !inventory.contains_min(item.item_id):
		return

	for slot : String in item.slots:
		if !equipment.has(slot):
			GlobalLogger.log_e(_PRE_LOG + "Cannot equip item(%s), invalid slot" % item.display_name)
			continue

		if !has_equipped(slot):
			equipment[slot] = item
			item.on_equipped.emit()
			equipment_modified.emit()
			remove_item_from_inventory(item.item_id)
			GameManager.get_ui().new_log(Log.new("Equipped [color=light_blue]%s[/color]" % item.display_name))
			return

	GameManager.get_ui().new_log(Log.new("No free slot available, unequip an item first"))
	pass

## Unequips an equipped item on slot `slot`
func unequip_item(slot : String):
	var item : Item = equipment.get(slot)
	if item == null:
		GlobalLogger.log_w(_PRE_LOG + "Nothing to unequip on slot(%s)" % slot)
		return

	equipment[slot] = null

	if item is Equippable:
		item.on_unequipped.emit()

	equipment_modified.emit()
	add_item_to_inventory(item.item_id)

	GameManager.get_ui().new_log(Log.new("Unequipped [color=light_blue]%s[/color]" % item.display_name))

## Returns true if there is an equipped item on the given `slot`
func has_equipped(slot : String) -> bool:
	if equipment.get(slot, null) == null:
		return false

	return true


func die():
	dead.emit()
