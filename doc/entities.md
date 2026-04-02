# Entities

Entities are interactable objects in the dungeon - enemies, NPCs, objects, etc. They are defined via JSON and can have custom behavior through type scripts.

---

## Overview

- **Base Class**: `Entity` (in `res://scripts/features/entities/entity.gd`)
- **Storage**: `res://entities/*.json`
- **Custom Types**: `res://scripts/features/entities/types/*.gd`

---

## Base Entity Properties

```gdscript
class_name Entity extends Resource

@export var base_health: float          # Maximum health
@export var display_name: String        # Shown to player
@export var description: String        # Lore text
@export var texture: Texture2D          # Sprite
@export var loot_table: Array          # Drop table
@export var combat_traits: Array[CombatTrait]  # AI behaviors
@export var flags: Dictionary           # Custom data
@export var id: String                  # Unique identifier
```

---

## Entity JSON Format

```json
{
    "display_name": "Slime",
    "description": "A squishy creature. Harmless-looking but dangerous.",
    "base_health": 10.0,
    "image_path": "slime",
    "type": "slime",
    "combat_traits": [
        {
            "trait_name": "dumb_hitter",
            "trait_parameters": {
                "amount": 3.0
            }
        }
    ],
    "loot_table": [
        {
            "item_id": "slime_drool",
            "chance": 0.7,
            "min_quantity": 1,
            "max_quantity": 3
        },
        {
            "item_id": "slime_heart",
            "chance": 0.05,
            "min_quantity": 1,
            "max_quantity": 1
        }
    ]
}
```

### Loot Table Format

| Field | Type | Description |
|-------|------|-------------|
| `item_id` | String | ID of item to potentially drop |
| `chance` | float | Probability (0.0-1.0) |
| `min_quantity` | int | Minimum drop count |
| `max_quantity` | int | Maximum drop count |

---

## Entity States

```gdscript
var is_dead: bool      # Whether entity is dead
var current_health: float  # Current HP (triggers death at 0)
var _current_room: Room   # Room entity is in
```

---

## Overridable Methods

| Public | Private | Description |
|--------|---------|-------------|
| `interact()` | `_interact()` | Player interacts (E key) |
| `on_attacked()` | `_on_attacked()` | Player attacks entity |
| `talk()` | `_talk()` | Player talks to entity |
| `die()` | `_die()` | Entity dies |
| `get_loot()` | `_get_loot()` | Get dropped items |
| `on_spawn()` | `_on_spawn()` | Entity spawns in room |
| `get_display_name()` | `_get_display_name()` | Dynamic name |
| `get_description()` | `_get_description()` | Dynamic description |
| `connect_to_fight()` | `_connect_to_fight()` | Combat setup |

### Example: Custom Interaction

```gdscript
class_name Merchant extends Entity

var _dialogue_started: bool = false

func _interact():
    if is_dead:
        GameManager.get_ui().new_log(Log.new("It's just a corpse..."))
        return
    GameManager.get_dialogue_manager().start_dialogue_by_name("lone_merchant", "intro")
```

---

## Custom Entity Types

### Creating a Type

1. Create script in `res://scripts/features/entities/types/[type_name].gd`
2. Extend `Entity`
3. Override desired methods

**`res://scripts/features/entities/types/merchant.gd`:**
```gdscript
class_name Merchant extends Entity

@export var shop_inventory: Array[String] = []

func _interact():
    GameManager.get_dialogue_manager().start_dialogue_by_name("merchant", "greeting")

func _on_attacked():
    GameManager.get_ui().new_log(Log.new("Attacking a merchant? Bad idea."))
    # Start fight or trigger consequences
```

### Using Custom Type

In entity JSON:
```json
{
    "display_name": "Lone Merchant",
    "type": "merchant",
    "type_properties": {
        "shop_inventory": ["apple", "meat", "water_vial"]
    }
}
```

### Type Properties

Custom parameters defined in JSON `type_properties` are automatically set on the entity:

```json
{
    "type": "slime",
    "type_properties": {
        "drool_factor": 54,
        "color": "green"
    }
}
```

```gdscript
class_name Slime extends Entity

@export var drool_factor: int = 10
@export var color: String = "blue"
```

---

## CombatTraits (Entity AI)

Entities use `CombatTrait` for combat behavior instead of equipment.

### Default Traits

| Trait | File | Description |
|-------|------|-------------|
| `dumb_hitter` | `dumb_hitter.gd` | Fixed damage each turn |
| `thorned` | `thorned.gd` | Heals when damaged |

### Adding Traits in JSON

```json
{
    "combat_traits": [
        {
            "trait_name": "dumb_hitter",
            "trait_parameters": {
                "amount": 5.0
            }
        },
        {
            "trait_name": "thorned",
            "trait_parameters": {
                "amount": 2
            }
        }
    ]
}
```

---

## Spawning Entities

Entities spawn when the player enters a room:

```gdscript
# Room instantiates entities on player entry
func instantiate_entities():
    for room_entity in room_entities:
        var spawned: Entity = _registry.get_entry_copy(room_entity)
        spawned.on_spawn()
        spawned._current_room = self
        instantiated_entities.append(spawned)
```

The entity's `_on_spawn()` is called - override for spawn behavior.

---

## Complete Example: Chest Entity

**`res://entities/chest.json`:**
```json
{
    "display_name": "Treasure Chest",
    "description": "A rusty wooden chest. Who knows what's inside?",
    "type": "chest"
}
```

**`res://scripts/features/entities/types/chest.gd`:**
```gdscript
class_name Chest extends Entity

var is_opened: bool = false

func _interact():
    if is_dead:
        GameManager.get_ui().new_log(Log.new("It's empty."))
        return
    
    if is_opened:
        GameManager.get_ui().new_log(Log.new("You already opened this chest."))
        return
    
    is_opened = true
    die()  # Mark as "dead" (opened)
    
    # Give loot
    var loot = get_loot()
    for loot_item in loot:
        GameManager.get_player_manager().player.add_item_to_inventory(
            loot_item["item_id"],
            loot_item["quantity"]
        )
    GameManager.get_ui().new_log(Log.new("You found: " + str(loot)))
```

---

## Adding New Entities

1. Create JSON at `res://entities/[entity_id].json`
2. Add texture to `res://resources/images/entities/[image_path].png`
3. If custom behavior needed, create type script in `res://scripts/features/entities/types/[type_name].gd`
4. Restart game to load

---

## Entity Datasource

Loads all entities from `res://entities/` at startup:

```gdscript
class_name EntityDatasource extends Node

func initialize():
    _load_entities()
    # Each entity registered to GameManager.get_registry()
```
