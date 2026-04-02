# Dialogue System

Dialogues are used for NPC conversations, story events, and interactive cutscenes.

---

## How Dialogues Work

1. **Structure**: Dialogues are arrays of `DialogueObject` entries
2. **Flow**: Each object displays text, optionally shows choices, then advances
3. **Events**: Dialogue objects can trigger game events (give items, start fights, etc.)
4. **Organization**: Dialogues are stored in `res://dialogues/[entity_name]/[dialogue_name].json`

---

## Dialogue JSON Format

```json
{
    "dialogue": [
        {
            "text": "NPC speaks this line"
        },
        {
            "text": "Second line of dialogue"
        },
        {
            "text": "Player can respond",
            "options": ["Yes", "No", "Goodbye"]
        },
        {
            "text": "Thanks!",
            "event": "give_item",
            "event_params": {"item_id": "apple", "quantity": 3}
        }
    ]
}
```

### Dialogue Object Fields

| Field | Type | Description |
|-------|------|-------------|
| `text` | String | What the NPC says |
| `options` | Array[String] | (Optional) Player choices |
| `event` | String | (Optional) Event to trigger |
| `event_params` | Dictionary | (Optional) Event parameters |

---

## DialogueObject Class

```gdscript
class_name DialogueObject

var text: String           # What NPC says
var options                # Array of choices or null
var event: String          # Event name or null
var event_params           # Event parameters or null
var has_event: bool        # True if this object has an event
```

---

## Dialogue Manager

Manages dialogue flow and state:

```gdscript
class_name DialogueManager

var current_dialogue: Dialogue
var current_object: DialogueObject
var is_dialogue: bool

signal dialogue_started
signal dialogue_next_object
signal dialogue_ended
signal dialogue_system_ready
```

### Key Methods

| Method | Description |
|--------|-------------|
| `start_dialogue_by_name(entity, name)` | Start specific dialogue |
| `start_random_dialogue(entity)` | Start random dialogue for entity |
| `next_object()` | Advance to next dialogue object |
| `end_current_dialogue()` | End current dialogue |

---

## Starting Dialogues

### From Entity

```gdscript
# In an entity type script
func _interact():
    GameManager.get_dialogue_manager().start_dialogue_by_name("lone_merchant", "intro_meet")
```

### From Dialogue Event

```json
{
    "text": "Take this gift!",
    "event": "give_item",
    "event_params": {"item_id": "apple", "quantity": 5}
}
```

---

## Dialogue Events

Events are defined in `DialogueEventManager` and called during dialogue.

### Default Events

| Event | Parameters | Description |
|-------|------------|-------------|
| `_deal_player_damage` | `dmg: float` | Deal damage to player |
| `_show_inventory_button` | none | Show inventory UI |

### Adding Custom Events

In `res://scripts/features/dialogue/dialogue_event_manager.gd`:

```gdscript
class_name DialogueEventManager extends Node

func _my_custom_event(param1: String = "default", param2: int = 1):
    # Handle the event
    GlobalLogger.log_i("Custom event: %s x%d" % [param1, param2])
    # Do something (give item, start fight, etc.)
```

Then trigger from JSON:
```json
{
    "text": "Something happens!",
    "event": "_my_custom_event",
    "event_params": {"param1": "hello", "param2": 5}
}
```

---

## Dialogue File Organization

```
res://dialogues/
├── [entity_name]/
│   ├── [dialogue_name_1].json
│   ├── [dialogue_name_2].json
│   └── ...
└── [another_entity]/
    └── ...
```

The entity name in the path must match the entity's ID (JSON filename without `.json`).

---

## Dialogue Datasource

Loads and manages all dialogues:

```gdscript
class_name DialogueDatasource

func get_dialogue_by_name(entity_name: String, dialogue_name: String) -> Dialogue
func get_random_dialogue_from(entity_name: String) -> Dialogue
```

---

## Complete Example

**`res://dialogues/lone_merchant/intro.json`:**
```json
{
    "dialogue": [
        {
            "text": "Hello, traveler! Welcome to my shop."
        },
        {
            "text": "I've got all sorts of goods... for the right price.",
            "options": ["Show me what you have", "Who are you?", "Never mind"]
        },
        {
            "text": "Take care on your journey!",
            "event": "_show_inventory_button"
        }
    ]
}
```

**Calling the dialogue:**
```gdscript
# In an entity script
func _interact():
    GameManager.get_dialogue_manager().start_dialogue_by_name("lone_merchant", "intro")
```
