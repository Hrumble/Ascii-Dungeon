# Game Architecture

This document covers the core systems that tie the game together.

---

## GameManager

The central hub that initializes and provides access to all game systems.

**Location**: `res://scenes/general/game_manager.tscn`

### Key Systems

| System | Accessor | Description |
|--------|----------|-------------|
| Registry | `GameManager.get_registry()` | Stores all game objects (items, entities) |
| PlayerManager | `GameManager.get_player_manager()` | Player state and management |
| DialogueManager | `GameManager.get_dialogue_manager()` | NPC conversations |
| RoomHandler | `GameManager.get_room_handler()` | Room generation and navigation |
| FightManager | `GameManager.get_fight_manager()` | Combat orchestration |
| CommandHandler | `GameManager.get_command_handler()` | Player input processing |
| UIManager | `GameManager.get_ui()` | Main game UI |

### Initialization Order

1. Registry
2. Datasources (Dialogue, Entity, Item, Room)
3. PlayerManager
4. DialogueManager
5. CommandHandler
6. RoomHandler
7. DialogueEventManager

---

## Registry

Central storage for all game objects (items, entities, etc.).

```gdscript
class_name Registry extends Node

var content: Dictionary[String, Object]
```

### Key Methods

| Method | Description |
|--------|-------------|
| `has(id)` | Check if entry exists |
| `get_entry_by_id(id)` | Get reference to entry |
| `get_entry_copy(id)` | Get duplicate of entry |
| `search_entries(query)` | Search by ID or display_name |

### Usage

```gdscript
var registry = GameManager.get_registry()

# Get item reference (shared)
var item = registry.get_entry_by_id("steel_sword")

# Get item copy (for inventory)
var item_copy = registry.get_entry_copy("steel_sword")
inventory.add_item(item_copy)
```

---

## PlayerManager

Manages player state and room navigation.

```gdscript
class_name PlayerManager extends Node

var player: MainPlayer
var current_state: GlobalEnums.PlayerState
var current_room: Room
var visited_rooms: Array[Vector2i]
```

### Player States

```gdscript
enum PlayerState {
    WANDERING,    # Exploring the dungeon
    IN_DIALOGUE,   # Talking to NPC
    FIGHTING       # In combat
}
```

### Signals

| Signal | Payload | Description |
|--------|---------|-------------|
| `entered_new_room` | `Vector2i` | Player enters undiscovered room |
| `entered_visited_room` | `Vector2i` | Player returns to known room |
| `state_changed` | `GlobalEnums.PlayerState` | Player state changed |

### Key Methods

| Method | Description |
|--------|-------------|
| `enter_room(room_pos)` | Move player to room |
| `set_state(new_state)` | Change player state |
| `set_to_previous_state()` | Restore previous state |

---

## MainPlayer

The player character class, extends `Entity`.

### Properties

```gdscript
var money: float
var inventory: Inventory
var equipment: Dictionary[EQUIPMENT_SLOTS, Equippable]
var dialogue_system: DialogueManager
```

### Key Methods

| Method | Description |
|--------|-------------|
| `equip_item(item)` | Equip an item |
| `unequip_item(slot)` | Unequip from slot |
| `add_item_to_inventory(item_id, qty)` | Add items |
| `get_equipped_items()` | Get all equipped items |

---

## Command Handler

Processes player text input commands.

### Command Prefix

All player-callable commands must be prefixed with `cmd_`:

```gdscript
func cmd_move(direction: String) -> bool:
    # Handle move command
    return true
```

### Built-in Commands

| Command | Usage | Description |
|---------|-------|-------------|
| `move` | `move <FRONT\|BACK\|LEFT\|RIGHT>` | Move between rooms |
| `interact` | `interact` | Interact with entity |
| `attack` | `attack` | Attack entity |
| `inventory` | `inventory` | Open inventory |
| `describe` | `describe` | Re-describe current room |
| `give` | `give <item_id> [amount]` | Debug: give item |

### Adding Custom Commands

```gdscript
# In res://scripts/features/command_handling/command_handler.gd

## My custom command
func cmd_my_command(arg1: String, arg2: String = "default") -> bool:
    GlobalLogger.log_i("Custom command: %s, %s" % [arg1, arg2])
    return true
```

---

## Global Enums

Located in `res://scripts/general/global_enums.gd`.

### Key Enums

```gdscript
enum PlayerState { WANDERING, IN_DIALOGUE, FIGHTING }

enum RARITY { COMMON = 1, UNCOMMON = 2, RARE = 3, UNHEARD = 4, INSANELY_RARE = 5 }

enum FIGHT_INTENTS { ATTACK, IDLE, BLOCK }

enum EQUIPMENT_SLOTS { HEAD, CHEST, LEGS, FEET, R_HAND, L_HAND, ... }

enum PATH_ID { FRONT, BACK, LEFT, RIGHT }
```

---

## Global Utilities

### GlobalLogger

Logging system (autoloaded as `GlobalLogger`).

```gdscript
GlobalLogger.log_i("Info message")      # General info
GlobalLogger.log_w("Warning message")   # Recoverable issue
GlobalLogger.log_e("Error message")     # Critical error
GlobalLogger.log_d("Debug message")     # Debug (requires debug mode)
```

### Utils

Common utility functions (autoloaded as `Utils`).

```gdscript
Utils.roll_chance(probability)                    # Returns bool (0.0-1.0)
Utils.pick_from_chance(items, chances)            # Weighted random selection
Utils.pick_from_weight(items, weights)            # Weighted random selection
Utils.skewed_random_distribution(min, max, bias)  # Biased random int
Utils.string_to_rarity(string)                    # Parse rarity string
Utils.string_to_equipment_slot(string)            # Parse slot string
```

---

## Autoloads Summary

| Name | Type | Purpose |
|------|------|---------|
| `GlobalLogger` | Logger | Logging utilities |
| `Utils` | Node | Utility functions |
| `GlobalEnums` | Node | All enum definitions |
| `UIAnimations` | Node | UI animation library |
| `GameManager` | Node | Central game state |
