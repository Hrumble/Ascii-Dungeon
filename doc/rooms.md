# Rooms System

Rooms are procedurally generated with various properties (tone, population, entities) that affect their description and content.

---

## How Rooms Work

1. **Generation**: When the player enters a new area, `RoomHandler.generate_room_at()` creates a room
2. **Properties**: Each room has randomly assigned properties (tone, info, entities)
3. **Connections**: Rooms connect to adjacent rooms based on probability (50% chance per direction)
4. **Persistence**: Generated rooms are cached - returning later shows the same room state

---

## Room Properties

### Categories

| Category | Description |
|----------|-------------|
| `CATEGORY.TONE` | Atmospheric properties (size, smell, temperature, etc.) |
| `CATEGORY.INFO` | Informational (population) |
| `CATEGORY.ENTITIES` | Entities present in the room |

### Tone Properties

| Property ID | Description |
|-------------|-------------|
| `SIZE` | Room size (small, medium, large, huge) |
| `AIR_QUALITY` | Air condition (dry, humid, fresh, etc.) |
| `SMELL` | Odor (none, dusty, moldy, rotting, etc.) |
| `TEMPERATURE` | Temperature (cold, warm, hot, freezing, etc.) |

### Property Definitions

Properties are defined in JSON templates at `res://rooms/templates/`:

```json
{
    "large": {
        "description": "massive",
        "chance": 0.2,
        "weight": 0.3
    },
    "small": {
        "description": "cramped",
        "chance": 0.3,
        "weight": 0.5
    }
}
```

Where:
- `description`: Text shown in room description
- `chance`: Probability of being selected (0.0-1.0)
- `weight`: Relative weight for weighted random selection
- `conditions` (optional): Required properties for this to appear
- `counter_conditions` (optional): Properties that prevent this from appearing

### Example: Population with Conditions

```json
{
    "settlement": {
        "description": "It's filled with people",
        "chance": 0.3,
        "weight": 0.5,
        "conditions": {
            "tone": {
                "size": ["large", "huge"]
            }
        },
        "counter_conditions": {
            "tone": {
                "smell": ["rotting", "sulfuring"],
                "temperature": ["hot", "freezing"]
            }
        }
    }
}
```

---

## Room Class

### Key Properties

```gdscript
var room_front: Room  # Room to the north
var room_back: Room   # Room to the south
var room_left: Room   # Room to the left
var room_right: Room  # Room to the right

var position: Vector2i  # Grid position
var room_entities: Array  # Entity IDs in room
var instantiated_entities: Array  # Actual entity instances
var has_entities_spawned: bool
```

### Key Methods

| Method | Description |
|--------|-------------|
| `set_path(direction, room)` | Set adjacent room |
| `get_path(direction)` | Get adjacent room (or null) |
| `instantiate_entities()` | Spawn entities in room |
| `get_room_description()` | Generate cached description |
| `mark_room_as_changed()` | Signal that room state changed |

---

## Room Templates Directory

```
res://rooms/
├── templates/
│   ├── tone/           # Atmospheric properties
│   │   ├── room_size.json
│   │   ├── room_smell.json
│   │   ├── room_air_quality.json
│   │   └── room_temperature.json
│   ├── info/           # Informational properties
│   │   └── room_population.json
│   └── entities/       # Entity spawn rules
└── pre_made/          # Hand-crafted rooms (future)
```

---

## Adding New Room Properties

### 1. Create Template File

**`res://rooms/templates/tone/room_my_property.json`:**
```json
{
    "value_a": {
        "description": "It feels pleasant here",
        "chance": 0.5,
        "weight": 0.5
    },
    "value_b": {
        "description": "Something feels off",
        "chance": 0.5,
        "weight": 0.5
    }
}
```

### 2. Register Property ID

In `res://scripts/features/rooms/room_properties.gd`:

```gdscript
const TONE_ID : Dictionary = {
    # ... existing ...
    MY_PROPERTY = "my_property"
}
```

### 3. Load in Room Handler

The `RoomHandler` automatically loads templates from `res://rooms/templates/` based on subdirectories.

---

## Room Generation Flow

```
Player enters new area
       ↓
RoomHandler.generate_room_at(position)
       ↓
Create Room object with random polygon
       ↓
Generate tone properties (size, smell, temperature, air_quality)
       ↓
Generate info properties (population) based on tone
       ↓
Generate entities based on tone and population
       ↓
Cache room and connect to adjacent rooms
       ↓
Player enters room → instantiate_entities() called
```

---

## Room Descriptions

Descriptions are generated from properties in order defined by `TONE_ID`:

```gdscript
# From room.gd:get_room_description()
full_description += "The room is "
full_description += "[size property] "
full_description += "[air_quality property] "
full_description += "[smell property] "
full_description += "[temperature property] "
full_description += "\n"
full_description += "[population property]"
```

Use BBCode for formatting: `[b]bold[/b]`, `[color=red]red[/color]`, etc.
