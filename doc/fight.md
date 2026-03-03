# Combat System

The combat system in this game is based on a series of event that get played one after the other. Each piece of equipment can react to an event by adding it's own action to the queue, and can also react to another equipment's action.
e.g.

"Enemy declares intent -> Sword deals damage -> Ring of health heals player on damage"

```gdscript
extends Equippable

@export var damage : float

func _connect_to_fight(_fight : Fight):
	_fight.on_run_attacks.connect(_on_run_attacks)

func _on_run_attacks(ctx : FightContext):
	ctx.add_to_action_queue(
		QueueAction.new(self, "damage", {"target": ctx.enemy, "amount": damage})
		)
	pass
```
Above is the code of the `general_damage_equippable.gd` item class, we will use this one as a simple example.

When the fight starts, the function `_connect_to_fight()` is called, it is our job to handle how this weapon/equipment behaves, in our case we connect the `_on_run_attacks()` method to the `on_run_attack` fight event:
```gdscript
func _connect_to_fight(_fight : Fight):
	_fight.on_run_attacks.connect(_on_run_attacks)
```
*Each event passes the **Fight Context**, which contains all the necessary informations about the current fight, and the current turn.*


