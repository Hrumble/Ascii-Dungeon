# Agent Guidelines for Ascii-Dungeon

## Project Overview

This is a **Godot 4.6** 2D dungeon crawler game. The codebase uses GDScript and follows specific conventions detailed below.

---

## Build/Lint/Test Commands

Since this is a Godot project (not Node.js), commands are run through Godot Editor or headless mode:

```bash
# Run the game (via Godot Editor or godot binary)
godot --path <project_path>

# Run in headless mode (for testing/automation)
godot --headless --path <project_path>

# Export the game
godot --headless --export-release <platform> <output_path>
```

**Note:** There is currently no formal test suite or linting tool configured. When adding tests, consider using GUT (Godot Unit Test) framework.

---

## Code Style Guidelines

### File Organization

```
scripts/
├── general/           # Utilities, singletons, base classes
│   ├── logger.gd
│   ├── utils.gd
│   ├── global_enums.gd
│   └── game_manager.gd
├── features/          # Feature modules
│   ├── combat/
│   │   ├── fight.gd
│   │   ├── fight_manager.gd
│   │   ├── traits/       # Combat trait system
│   │   └── presentation/  # UI scenes
│   ├── items/
│   │   ├── item.gd
│   │   ├── types/         # Item type scripts
│   │   └── presentation/
│   ├── entities/
│   │   ├── entity.gd
│   │   └── types/         # Entity type scripts
│   └── [other features...]
├── player/
│   ├── player.gd
│   └── player_manager.gd
└── parent_ui/
    └── game_ui.gd

entities/              # JSON entity definitions
items/                 # JSON item definitions
dialogues/             # JSON dialogue definitions
rooms/                 # JSON room definitions
scenes/                # Scene files (.tscn)
resources/             # Textures, audio, etc.
doc/                   # Documentation
```

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Classes | PascalCase | `class_name Fight extends Node` |
| Files | snake_case.gd | `fight.gd`, `item_datasource.gd` |
| Variables | snake_case | `current_health`, `display_name` |
| Functions | snake_case | `get_item()`, `start_fight()` |
| Constants | _PREFIX_SNAKE | `_PRE_LOG`, `_INFO_PRE` |
| Enums | UPPER_SNAKE_CASE | `RARITY`, `PLAYER_STATE` |
| Enum values | UPPER_SNAKE_CASE | `RARITY.COMMON`, `FIGHT_INTENTS.ATTACK` |
| Private variables | _prefix | `_player_manager`, `_current_step` |
| Signal names | snake_case | `signal health_changed` |

### Type Annotations

Always use explicit type annotations for variables and return types:

```gdscript
var _player : MainPlayer
var items : Array[Item]
var equipment : Dictionary[GlobalEnums.EQUIPMENT_SLOTS, Equippable]

func get_item(item_id : String) -> Item:
    pass
```

### Enums

Enums are defined in `scripts/general/global_enums.gd` as global constants (not nested in classes):

```gdscript
enum RARITY {
    COMMON = 1,
    UNCOMMON = 2,
    RARE = 3,
}

enum FIGHT_INTENTS {
    ATTACK,
    IDLE,
    BLOCK
}
```

Use `GlobalEnums.RARITY.COMMON` to reference enum values.

### Imports and Autoloads

The following singletons are autoloaded and available globally:

- `GlobalLogger` - Logging utility (`log_i()`, `log_w()`, `log_e()`, `log_d()`)
- `Utils` - Utility functions
- `GlobalEnums` - All enum definitions
- `UIAnimations` - UI animation library
- `GameManager` - Central game state manager

```gdscript
# No import needed - available globally
GlobalLogger.log_i("Player initialized")
var health : float = Utils.clamp_value(current_health, 0.0, base_health)
```

### Error Handling

Use the `GlobalLogger` for all logging:

```gdscript
# Info - general information
GlobalLogger.log_i("Fight started with %s" % enemy_name)

# Warning - recoverable issues
GlobalLogger.log_w("Item %s not found in registry" % item_id)

# Error - critical issues
GlobalLogger.log_e("Failed to load texture at %s" % path)

# Debug - only shows when debug mode enabled
GlobalLogger.log_d("Player moved to position %s" % position)
```

For null checks and validation:
```gdscript
if parsed_json == null:
    GlobalLogger.log_e("Could not parse JSON")
    return null

if not content.has(id):
    GlobalLogger.log_e("entry with id (%s) does not exist" % id)
    return null
```

### Class Structure Pattern

Use the public/private method pattern for overridable behavior:

```gdscript
class_name Item extends Resource

# Public method - calls private implementation
func use():
    _use()
    pass

# Private implementation - meant to be overridden by subclasses
func _use():
    pass

# Initialize hook pattern
func initialize():
    _initialize()
    pass

func _initialize():
    pass
```

### JSON Data Loading

Resources (Items, Entities, Dialogues) are loaded from JSON files in `res://items/`, `res://entities/`, etc. Use the `fromJSON()` static factory method:

```gdscript
static func fromJSON(json : String, _item_id : String) -> Item:
    var parsed_json : Dictionary = JSON.parse_string(json)
    if parsed_json == null:
        return null
    # ... process and return item
```

### Comments and Documentation

Use `##` for docstring-style comments on functions:

```gdscript
## Returns a random number between `min` and `max`
## Higher chance to get lower numbers. Change `bias` to favor odds
func skewed_random_distribution(min : int, max : int, bias : float = 2.0) -> int:
    pass
```

Use section separators for code organization:

```gdscript
#--------------------------------------------------------------------#
#                               Events                               #
#--------------------------------------------------------------------#
```

### Constants

Define class-level constants with `_PREFIX`:

```gdscript
const _PRE_LOG : String = "Item> "
const ITEM_DIR : String = "res://items/"
```

### Signals

Define signals at the top of the class after variables:

```gdscript
class_name Fight extends Node

var turn_count : int = 0

signal running_step(id : String)
signal fight_end(winner : Entity, loser : Entity)
```

### Export Variables

Use `@export` for editor-configurable properties:

```gdscript
@export var display_name : String
@export var rarity : GlobalEnums.RARITY = GlobalEnums.RARITY.COMMON
@export var texture : Texture2D
```

Group exports with `@export_subgroup`:

```gdscript
@export_subgroup("Buttons")
@export var _inventory_button : Button
@export var _registry_button : Button
```

---

## JSON Schema Patterns

### Item Definition
```json
{
    "display_name": "Steel Sword",
    "description": "A sturdy blade",
    "value": 100.0,
    "rarity": "RARE",
    "image_path": "steel_sword",
    "type": "weapon",
    "type_properties": {
        "damage": 15.0
    }
}
```

### Entity Definition
```json
{
    "display_name": "Slime",
    "description": "A squishy creature",
    "base_health": 10.0,
    "loot_table": [
        {"item_id": "slime_drool", "chance": 0.7, "min_quantity": 1, "max_quantity": 3}
    ],
    "type": "slime",
    "type_properties": {}
}
```

---

## Common Patterns

### Singleton Access
```gdscript
# Get player
var player = GameManager.get_player_manager().player

# Get registry
var registry = GameManager.get_registry()

# Get UI
var ui = GameManager.get_ui()
```

### Equipment System
Items that can be equipped extend `Equippable` and define valid slots:
```gdscript
class_name Weapon extends Equippable

@export var damage : float

func _connect_to_fight(_fight : Fight):
    _fight.on_run_attacks.connect(_on_run_attacks)
```

### Combat System
Equipment connects to fight signals and adds actions to the queue:
```gdscript
func _on_run_attacks(ctx : FightContext):
    ctx.add_to_action_queue(
        QueueAction.new(self, "damage", {"target": ctx.enemy, "amount": damage})
    )
```

---

## File Locations Reference

| Resource Type | Location |
|--------------|----------|
| Items | `res://items/*.json` |
| Entities | `res://entities/*.json` |
| Dialogues | `res://dialogues/*/` |
| Rooms | `res://rooms/pre_made/*.json` |
| Room Templates | `res://rooms/templates/*/` |
| Item Types | `res://scripts/features/items/types/*.gd` |
| Entity Types | `res://scripts/features/entities/types/*.gd` |
| Combat Traits | `res://scripts/features/combat/traits/*.gd` |
| Scenes | `res://scenes/` or feature subdirectories |

---

## Important Notes

1. **No formal test suite exists** - Write tests if adding functionality that warrants them
2. **No linter configured** - Follow the conventions in this document
3. **Godot 4.6 specific** - Use Godot 4.x syntax (not Godot 3.x)
4. **Third-party assets** - Some sprites are from itch.io (see readme.md for license details)
5. **Current TODOs** - See readme.md for planned features and known bugs
