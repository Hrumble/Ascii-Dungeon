# Items System

Items are defined via JSON files in `res://items/` and loaded by the `ItemDatasource` at runtime.

---

## Item Class Hierarchy

```
Item (base class)
├── Equippable (can be equipped by player)
│   ├── Weapon (damage dealing items)
│   └── [Custom types]
├── Consumable (items that can be consumed)
└── [Custom types]
```

---

## Base Item Properties

All items support these properties:

| Property | Type | Description |
|----------|------|-------------|
| `display_name` | String | Shown to the player |
| `description` | String | Item lore/description |
| `value` | float | Monetary value |
| `rarity` | String | `COMMON`, `UNCOMMON`, `RARE`, `UNHEARD`, `INSANELY_RARE` |
| `image_path` | String | Filename in `res://resources/images/items/` |
| `flags` | Dictionary | Custom key-value storage |
| `type` | String | Custom item script (see below) |
| `type_properties` | Dictionary | Values for custom type properties |

---

## JSON Example: Basic Item

```json
{
    "display_name": "Apple",
    "description": "A fresh red apple. Restores health.",
    "value": 5.0,
    "rarity": "COMMON",
    "image_path": "apple",
    "flags": {
        "heal_amount": 2.0
    }
}
```

---

## Custom Item Types

For items with custom logic, create a script in `res://scripts/features/items/types/`.

### Basic Structure

```gdscript
class_name MyItem extends Item  # or Equippable, Weapon, etc.

@export var my_property : float

func _initialize():
    # Called after item is parsed from JSON
    pass
```

### JSON with Custom Type

```json
{
    "display_name": "Steel Sword",
    "type": "general_damage_equippable",
    "type_properties": {
        "damage": 3.0,
        "slots": ["R_HAND", "L_HAND"]
    }
}
```

The game will look for `res://scripts/features/items/types/general_damage_equippable.gd`.

---

## Equippable Items

Equippables can be worn by the player. They define valid `slots`:

```gdscript
class_name MyEquippable extends Equippable

func _init():
    slots = ["R_HAND", "L_HAND"]  # Valid equipment slots
```

### Equipment Slots

| Slot | Description |
|------|-------------|
| `HEAD` | Helmet/hat |
| `CHEST` | Armor |
| `LEGS` | Pants |
| `FEET` | Boots |
| `R_HAND` | Right hand (weapons) |
| `L_HAND` | Left hand (weapons/shields) |
| `R_FINGER_0`, `R_FINGER_1` | Right hand rings |
| `L_FINGER_0`, `L_FINGER_1` | Left hand rings |
| `BELT_1`, `BELT_2` | Belt slots |

---

## Combat-Reactive Equipment

Equipment can react to fight events. See [Combat System](./fight.md) for details.

### Example: Ring of Health (Reactive Item)

```gdscript
# res://scripts/features/items/types/ring_of_health.gd
extends Equippable

func _react_to_action(action : QueueAction, ctx : FightContext):
    # React when player takes damage
    if action.action == "damage" and action.parameters["target"] == ctx.player_manager.player:
        ctx.add_to_reaction_queue(QueueAction.new(
            self,
            "heal",
            {"target": ctx.player_manager.player, "amount": 1}
        ))
    f_has_reacted = true
```

### Example: Damage Weapon

```gdscript
# res://scripts/features/items/types/general_damage_equippable.gd
extends Equippable

@export var damage : float

func _connect_to_fight(_fight : Fight):
    _fight.on_run_attacks.connect(_on_run_attacks)

func _on_run_attacks(ctx : FightContext):
    ctx.add_to_action_queue(
        QueueAction.new(self, "damage", {"target": ctx.enemy, "amount": damage})
    )
```

---

## Adding New Items

1. Create JSON file in `res://items/[item_id].json`
2. If custom logic needed, create script in `res://scripts/features/items/types/[type_name].gd`
3. Add texture to `res://resources/images/items/[image_path].png`
4. Restart game to load

### Complete Example

**`res://items/ring_of_health.json`:**
```json
{
    "display_name": "Ring of Health",
    "description": "Heals you when you take damage",
    "value": 100.0,
    "image_path": "ruby_ring",
    "type": "ring_of_health",
    "rarity": "RARE",
    "type_properties": {
        "slots": ["R_FINGER_0", "R_FINGER_1", "L_FINGER_0", "L_FINGER_1"]
    }
}
```

**`res://scripts/features/items/types/ring_of_health.gd`:**
```gdscript
extends Equippable

func _react_to_action(action : QueueAction, ctx : FightContext):
    if action.action == "damage" and action.parameters["target"] == ctx.player_manager.player:
        ctx.add_to_reaction_queue(QueueAction.new(
            self,
            "heal",
            {"target": ctx.player_manager.player, "amount": 1}
        ))
    f_has_reacted = true
```
