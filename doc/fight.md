# Combat System

The combat system is turn-based where the player builds synergies through equipment combinations. The player doesn't directly control combat - they watch it unfold while their equipment handles the action.

---

## Overview

Combat flows through **events** that trigger **actions**. Equipment can:
1. **Add actions** to the queue during events
2. **React to actions** resolved by other equipment

### Example Synergy

```
Sword attacks → Enemy takes damage → Ring of Health heals player
```

---

## Fight Flow

Each turn consists of these events in order:

| Event | Signal | Description |
|-------|--------|-------------|
| Start Turn | `on_turn_start` | Turn begins, cleanup if needed |
| Run Attacks | `on_run_attacks` | All equipment adds attack actions |
| End Turn | `on_turn_end` | Turn ends, check for victory/defeat |

### Turn Cycle

```
Fight.start_fight()
       ↓
[Turn 1]
  on_turn_start → on_run_attacks → on_turn_end
       ↓
[Turn 2] (if no one dead)
  on_turn_start → on_run_attacks → on_turn_end
       ↓
... repeat until someone dies
       ↓
fight_end.emit(winner, loser)
```

---

## FightContext

Passed to all event handlers, contains combat state:

```gdscript
class_name FightContext extends Node

var enemy: Entity              # Current opponent
var player_manager: PlayerManager
var step: int                  # Current event index
var fight: Fight               # Reference to fight
var action_queue: Array[QueueAction]    # Actions to resolve
var reaction_queue: Array[QueueAction]   # Reactions to resolve
var flags: Dictionary           # Custom combat data
```

### Key Methods

| Method | Description |
|--------|-------------|
| `add_to_action_queue(action)` | Add action to resolve |
| `add_to_reaction_queue(action)` | Add reaction to action |

---

## QueueAction

Represents a single combat action:

```gdscript
class_name QueueAction

var source: Object    # Who triggered this
var action: String     # Action name to call
var parameters: Dictionary  # Parameters for action
```

### Creating Actions

```gdscript
QueueAction.new(source, action_name, {"param1": value, "param2": value})
```

### Built-in Actions

| Action | Parameters | Description |
|--------|------------|-------------|
| `damage` | `target`, `amount` | Deal damage |
| `heal` | `target`, `amount` | Restore health |

---

## Equipment Combat Integration

### Connecting to Fight

```gdscript
class_name MyEquippable extends Equippable

func _connect_to_fight(_fight: Fight):
    _fight.on_run_attacks.connect(_on_run_attacks)
```

### Adding Actions

```gdscript
func _on_run_attacks(ctx: FightContext):
    ctx.add_to_action_queue(
        QueueAction.new(self, "damage", {"target": ctx.enemy, "amount": 5.0})
    )
```

---

## Reactive Equipment

Equipment can react to actions from other sources.

### React Method

```gdscript
func _react_to_action(action: QueueAction, ctx: FightContext):
    # Check the action
    if action.action == "damage" and action.parameters["target"] == ctx.player_manager.player:
        # React by healing player
        ctx.add_to_reaction_queue(QueueAction.new(
            self, "heal",
            {"target": ctx.player_manager.player, "amount": 1}
        ))
    # Prevent infinite loops
    f_has_reacted = true
```

### Loop Prevention

The `f_has_reacted` flag prevents equipment from reacting multiple times per action. Set it to `true` after your reaction.

---

## CombatTraits (Entity AI)

Entities use `CombatTrait` scripts instead of equipment.

### Creating a Trait

**`res://scripts/features/combat/traits/my_trait.gd`:**
```gdscript
class_name MyTrait extends CombatTrait

@export var damage: float = 3.0

func _connect_to_fight(_fight: Fight):
    _fight.on_run_attacks.connect(_on_run_attacks)

func _on_run_attacks(ctx: FightContext):
    ctx.add_to_action_queue(
        QueueAction.new(ctx.enemy, "damage", {"target": ctx.player_manager.player, "amount": damage})
    )

func _get_name() -> String:
    return "My Trait Name"

func _get_description() -> String:
    return "What this trait does"
```

### Adding Traits to Entity

In entity JSON:
```json
{
    "combat_traits": [
        {
            "trait_name": "my_trait",
            "trait_parameters": {
                "damage": 5.0
            }
        }
    ]
}
```

### Built-in Traits

| Trait | Description |
|-------|-------------|
| `dumb_hitter` | Deals fixed damage each turn |
| `thorned` | Heals on taking damage |

---

## Complete Example: Damage Weapon

**`res://scripts/features/items/types/my_sword.gd`:**
```gdscript
extends Equippable

@export var damage: float = 10.0

func _connect_to_fight(_fight: Fight):
    _fight.on_run_attacks.connect(_on_run_attacks)

func _on_run_attacks(ctx: FightContext):
    ctx.add_to_action_queue(
        QueueAction.new(self, "damage", {"target": ctx.enemy, "amount": damage})
    )
```

---

## Complete Example: Reactive Ring

**`res://scripts/features/items/types/life_stealer.gd`:**
```gdscript
extends Equippable

@export var heal_percent: float = 0.2

func _react_to_action(action: QueueAction, ctx: FightContext):
    if action.action == "damage" and action.parameters["target"] == ctx.enemy:
        var damage_amount = action.parameters["amount"]
        ctx.add_to_reaction_queue(QueueAction.new(
            self, "heal",
            {"target": ctx.player_manager.player, "amount": damage_amount * heal_percent}
        ))
    f_has_reacted = true
```

---

## Important Notes

1. **No `await` in event handlers** - May cause unpredictable behavior
2. **Loop prevention** - Always set `f_has_reacted = true` in reactions
3. **Source check** - Don't react to your own actions (already handled)
4. **Equipment duplicates** - Equipped items are duplicated, not shared references

---

## Signals Reference

### Fight Signals

| Signal | Payload | Description |
|--------|---------|-------------|
| `running_step` | `String` (step name) | A step is starting |
| `on_turn_start` | `FightContext` | Turn beginning |
| `on_run_attacks` | `FightContext` | Attack phase |
| `on_turn_end` | `FightContext` | Turn ending |
| `fight_end` | `Entity`, `Entity` | Combat finished |

### FightSequencer Signals

| Signal | Description |
|--------|-------------|
| `action_resolved` | An action completed |
| `reactions_done` | All reactions for action resolved |
