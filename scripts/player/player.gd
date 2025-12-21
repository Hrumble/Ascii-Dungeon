class_name MainPlayer extends Entity

const _PRE_LOG: String = "MainPlayer> "

## The current room the player is in
var current_room: Vector2i
var previous_room: Vector2i
## The rooms the player has previously been to. Does not include the current room
var visited_positions: Array[Vector2i]

var _game_ui: MainGameUI
var _registry: Registry

var player_position: Vector2i

var money: float
var inventory: Inventory
var combat_move_container: CombatMoveContainer

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
## Gets called when the player enters a new room
signal entered_new_room(room_pos: Vector2i)
## The player enters a room he's been in before
signal entered_visited_room(room_pos: Vector2i)
## The player enters a room, wether visited or not
signal entered_room(room_pos: Vector2i)
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
	player_position = Vector2i(0, 0)

	current_health = base_health
	current_sp = base_sp

	# Initializes inventory
	inventory = Inventory.new()
	add_item_to_inventory("apple", 8)
	add_item_to_inventory("jar", 2)
	add_item_to_inventory("spider_leg")

	# Initializes combat_move_container
	combat_move_container = CombatMoveContainer.new()
	combat_move_container.add_move("combat_basic_strike")
	combat_move_container.add_move("combat_block")

func _ready():
	dialogue_system = GameManager.get_dialogue_manager()

func add_item_to_inventory(item_id: String, quantity: int = 1):
	_get_ui()
	if !_game_ui == null:
		_game_ui.new_log(
			Log.new(
				"",
				(
					"received %sx %s"
					% [quantity, _registry.get_entry_property(item_id, "display_name")]
				),
				GlobalEnums.LogType.GAME_INFO
			)
		)
	inventory.add_item(item_id, quantity)
	pass


func enter_room(room_pos: Vector2i):
	GlobalLogger.log_i(_PRE_LOG + "Player entering room %s " % room_pos)
	previous_room = current_room
	current_room = room_pos
	if room_pos in visited_positions:
		entered_visited_room.emit(room_pos)
	else:
		visited_positions.append(room_pos)
		entered_new_room.emit(room_pos)
	entered_room.emit(room_pos)

func _get_weapon() -> String:
	return "steel_sword"

func _take_hit(weapon: Weapon):
	GlobalLogger.log_d(_PRE_LOG + "Player takes hit from: %s" % weapon.display_name)
	current_health -= weapon.damage
	took_damage.emit(weapon.damage)
	if current_health <= 0:
		die()

func die():
	dead.emit()
