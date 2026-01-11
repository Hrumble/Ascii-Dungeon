class_name MainPlayer extends Entity

const _PRE_LOG: String = "MainPlayer> "


var _game_ui: MainGameUI
var _registry: Registry

var money: float
var inventory: Inventory
var combat_move_container: CombatMoveContainer

## Do not use, prefer getting the current room from the player manager instead
## This variable is used for entities that are spawned within rooms, this is not the case for the player and therefore will always return null
var current_room : Room = null

## The attributes are properties the player logic is based on
## Not implemented
# var attributes: Dictionary = {MAX_HEALTH = 10.0, BASE_ATTACK_DAMAGE = 5.0}

var equipment: Dictionary = {
	HEAD = null,
	CHEST = null,
	LEGS = null,
	FEET = null,
	R_HAND = null,
	L_HAND = null,
	BELT = null,
}

var dialogue_system: DialogueManager

signal took_damage(dmg: float)
signal dead

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

	# Initializes combat_move_container
	combat_move_container = CombatMoveContainer.new()
	combat_move_container.add_move("combat_basic_strike")

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



func _get_weapon() -> Weapon:
	return null

func _take_hit(weapon: Weapon):
	GlobalLogger.log_d(_PRE_LOG + "Player takes hit from: %s" % weapon.display_name)
	current_health -= weapon.damage
	took_damage.emit(weapon.damage)
	if current_health <= 0:
		die()

func die():
	dead.emit()
