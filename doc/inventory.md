# Inventory System

The inventory system manages items the player carries, including equipping gear.

---

## Inventory Class

```gdscript
class_name Inventory

var content: Dictionary  # item_id → InventoryItem

signal inventory_modified
signal count_updated(item_id: String, count: int)
```

---

## InventoryItem

Wraps an item with quantity tracking:

```gdscript
class_name InventoryItem extends Node

var item_id: String
var item_quantity: int
var item: Item  # Reference to actual item
```

---

## Key Methods

| Method | Description |
|--------|-------------|
| `add_item(item_id, qty)` | Add items (creates copy from registry) |
| `remove_item(item_id)` | Remove all of item |
| `remove_item_quantity(item_id, qty)` | Remove specific amount |
| `contains_min(item_id, qty)` | Check if has minimum quantity |
| `get_item(item_id)` | Get item reference from registry |
| `get_items()` | Get all InventoryItems |

---

## Usage

```gdscript
var inventory = player.inventory

# Add items
inventory.add_item("apple", 5)
inventory.add_item("steel_sword", 1)

# Check items
if inventory.contains_min("apple", 3):
    print("You have enough apples!")

# Get item for equipping
var sword = inventory.get_item("steel_sword")
if sword:
    player.equip_item(sword)

# Remove items
inventory.remove_item_quantity("apple", 2)
```

---

## Equipment System

Players equip items to slots for combat benefits.

### Equipment Dictionary

```gdscript
var equipment: Dictionary[EQUIPMENT_SLOTS, Equippable]

# Default slots:
equipment[HEAD] = null
equipment[CHEST] = null
equipment[LEGS] = null
equipment[FEET] = null
equipment[R_HAND] = null
equipment[L_HAND] = null
equipment[R_FINGER_0] = null
equipment[R_FINGER_1] = null
equipment[L_FINGER_0] = null
equipment[L_FINGER_1] = null
equipment[BELT_1] = null
equipment[BELT_2] = null
```

### Equipping Items

```gdscript
func equip_item(item: Equippable):
    # Check if in inventory
    if !inventory.contains_min(item.id):
        return
    
    # Equip to first valid slot
    for slot in item.slots:
        if !has_equipped(slot):
            equipment[slot] = item.duplicate()
            item.on_equipped.emit()
            remove_item_from_inventory(item.id)
            return
```

### Unequipping Items

```gdscript
func unequip_item(slot: EQUIPMENT_SLOTS):
    var item = equipment.get(slot)
    if item == null:
        return
    
    equipment[slot] = null
    item.on_unequipped.emit()
    add_item_to_inventory(item.id)
```

---

## ItemSlot (UI)

The UI representation of an inventory slot.

```gdscript
class_name ItemSlot extends Control

@export var slot_type: EQUIPMENT_SLOTS
@export var show_background: bool = true
```

Features:
- Drag and drop support
- Right-click context menu
- Tooltip on hover
- Visual feedback for valid/invalid drops
