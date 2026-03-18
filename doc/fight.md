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

The `_on_run_attacks()` function will run, when the **on_run_attacks** event is processed in the fight, it will promptly add an action to queue, see [##QueueActions].
>![WARNING]
> You must not, and can not `await` anything inside the functions that react to fight events, this may lead to unintended and unpredictable behavious


## QueueActions

Each action is added to the turn queue as a `QueueAction`. A Queue Action is defined with the following parameters:

| Parameter | Type | Description |
|-----------|------|-------------|
|source     | Object | The object from which this action is coming from, used mainly so the fight ui knows what to display|
|action | String | The action to be executed, each action must be present in both the `fight.gd` file, and the `fight_ui.gd` file to be executed correctly |
| parameters | Dictionnary | A dictionary of parameters passed to the appropriately called function refered to by `action`. The parameters can be given any names, as long as the naming and ordering is consistent with the appropriate function. `callv(action, parameters.values())` is called in both the Fight file, then the FightUI file. Use the key names to refer to each parameter for specific behaviour later. |


### List of Actions

| action name | parameters(in order) | description |
|-------------|----------------------|-------------|
| damage | target : `Object`, amount : `float` | Deals *amount* damage to *target*|
| heal | target : `Object`, amount : `float` | Heals *amount* hp to *target*|
