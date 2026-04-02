# Getting Started

This guide helps you start contributing to Ascii-Dungeon.

---

## Project Structure

```
Ascii-Dungeon/
├── doc/                    # Documentation
├── dialogues/              # Dialogue JSON files
│   └── [entity_name]/
│       └── [dialogue_name].json
├── entities/               # Entity JSON files
│   └── [entity_id].json
├── items/                  # Item JSON files
│   └── [item_id].json
├── rooms/
│   ├── pre_made/          # Hand-crafted rooms
│   └── templates/          # Room property definitions
├── resources/
│   ├── images/
│   │   ├── entities/      # Entity sprites
│   │   └── items/         # Item sprites
│   └── tiles/             # UI tiles
├── scenes/                # Godot scenes
├── scripts/
│   ├── features/          # Feature modules
│   │   ├── combat/        # Combat system
│   │   ├── dialogue/      # Dialogue system
│   │   ├── entities/      # Entity system
│   │   ├── items/         # Item system
│   │   ├── inventory/     # Inventory UI
│   │   └── rooms/         # Room generation
│   ├── general/           # Utilities, globals
│   └── parent_ui/         # Main UI
└── UI/                    # UI components
```

---

## Running the Game

```bash
# Using Godot binary (faster startup)
godot --path /path/to/Ascii-Dungeon

# Using Godot Editor
# Open the project.godot file
```

---

## Adding Content

### 1. Add a New Item

**Create JSON** at `items/my_item.json`:
```json
{
    "display_name": "My Item",
    "description": "A thing I made",
    "value": 10.0,
    "rarity": "COMMON"
}
```

**Add texture** at `resources/images/items/my_item.png`

### 2. Add a New Entity

**Create JSON** at `entities/my_entity.json`:
```json
{
    "display_name": "My Entity",
    "description": "Something in the dungeon",
    "base_health": 20.0,
    "loot_table": [
        {"item_id": "my_item", "chance": 1.0, "min_quantity": 1, "max_quantity": 2}
    ]
}
```

**Add texture** at `resources/images/entities/my_entity.png`

### 3. Add Custom Item Behavior

Create script at `scripts/features/items/types/my_item.gd`:
```gdscript
class_name MyItem extends Item

@export var my_property: float = 5.0

func _initialize():
    GlobalLogger.log_i("My custom item initialized!")
```

Reference in JSON:
```json
{
    "display_name": "Special Item",
    "type": "my_item",
    "type_properties": {
        "my_property": 10.0
    }
}
```

### 4. Add a Dialogue

Create file at `dialogues/my_npc/greeting.json`:
```json
{
    "dialogue": [
        {"text": "Hello!"},
        {"text": "Welcome to my shop."}
    ]
}
```

Trigger from entity:
```gdscript
func _interact():
    GameManager.get_dialogue_manager().start_dialogue_by_name("my_npc", "greeting")
```

---

## Key Files

| System | Main Script | JSON Path |
|--------|------------|-----------|
| Items | `item.gd` | `items/*.json` |
| Entities | `entity.gd` | `entities/*.json` |
| Dialogues | `dialogue.gd` | `dialogues/*/` |
| Rooms | `room.gd` | `rooms/templates/` |
| Combat | `fight.gd` | N/A |

---

## Code Conventions

See [AGENTS.md](../AGENTS.md) for detailed conventions:

- **Files**: `snake_case.gd`
- **Classes**: `PascalCase`
- **Variables**: `snake_case`
- **Constants**: `_PREFIX_SNAKE`
- **Private**: `_prefix`
- **Enums**: `UPPER_SNAKE_CASE`
- **Type annotations**: Always use explicit types

---

## Debug Commands

In-game commands for testing:

| Command | Description |
|---------|-------------|
| `give <item_id> [amount]` | Add item to inventory |
| `describe` | Re-describe current room |

---

## Common Patterns

### Adding Equipment Combat Logic

```gdscript
# In item type script
extends Equippable

func _connect_to_fight(_fight: Fight):
    _fight.on_run_attacks.connect(_on_run_attacks)

func _on_run_attacks(ctx: FightContext):
    ctx.add_to_action_queue(
        QueueAction.new(self, "damage", {"target": ctx.enemy, "amount": 5.0})
    )
```

### Entity Interaction

```gdscript
# In entity type script
func _interact():
    GameManager.get_dialogue_manager().start_dialogue_by_name("npc_id", "dialogue_name")
```

### Room Navigation

```gdscript
# Check available paths
if current_room.room_front:
    print("Can go forward!")

# Move player
player_manager.enter_room(current_room.room_front.position)
```

---

## Testing Changes

1. Save files
2. Restart Godot (or use hot-reload if available)
3. Check console for errors
4. Test the specific feature

---

## Getting Help

- Read existing code in `doc/`
- Check `scripts/features/` for implementation examples
- Use `GlobalLogger.log_i/w/e/d()` for debugging
- Consult `AGENTS.md` for conventions
