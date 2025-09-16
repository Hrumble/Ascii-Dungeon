```gdscript
class_name Entity
```

# Description
An entity is an interactable object in the world, most of them can spawn naturally. Each entity, like [Item](./items.md) is defined through a json file located at
`res://entities/[entity_id].json`.

# Class Definition

```gdscript

class_name Entity extends Resource

@export var base_health : float # The base health of the entity
@export var base_attack_damage : float # The base attack damage of the entity
@export var display_name : String # The display name
@export var description : String # The description
@export var loot_table : Array # The loot table

@export var can_escape : bool # In a fight, can the user escape this entity 
```


## Available Funtions

|function      |description| Return type|
|--------------|---------|-----------|
|interact()   | What happens when the user interacts with this entity| None |
|on_attacked() | What happens when the player attacks this entity | None|
|talk() | What happens when the player talks to this entity| None|
|die() | What happens when this entity dies| None |
|get_loot() | How do you get the loot available from this entity| Dictionnary `{"item_id" : item_quantity}`|


## Creating an entity

>[!WARNING]
> The following is promoting every single parameter available for an entity, each parameter can by default be ommited for a default value, you do not have to define every
> single property

```json
{
	"display_name" : "Slime",
	"description" : "squishy, it seems harmless, but judging by what we can see in his translucent stomach, we've got to stay alert",
	"base_health" : 10.0, 
	"base_attack_damage" : 2.0,
	"loot_table" : [
		{
			"item_id" : "slime_drool",
			"chance" : 0.7,
			"min_quantity" : 1,
			"max_quantity" : 3
		},
		{
			"item_id" : "slime_heart",
			"chance" : 0.05,
			"min_quantity" : 1,
			"max_quantity" : 1
		}
	],
	"type": "slime",
	"type_properties" : {
		"drool_factor" : 54
	}
}
```

# The type
Each entity, will, unless specified be of the main `Entity` type. However, in some cases you might need an entity that has specific logic. To do so, create a script inside the 
`[entity_feature_path]/types/[my_type].gd`. Be mindful that the name of the script will be used to reference the type. If you specify `"type" : "slime"` it will look for `slime.gd`

The new "type" must extend `Entity`, and can have any number of parameters, as long as those are able to be defined in JSON format.

## Specifying type parameters
Custom type, means custom parameters. you can specify those parameters inside the **json** file of the entity using the key `type_properties`. This value is a dictionary that matches
`"variable_name" : variable value`.

In the case of our slime here
```json
"type_properties" : {
    "drool_factor" : 54
}
```
When being parsed, the parser will attempt to set the value of the variable `drool_factor` to `54`.

>[!WARNING]
> You can sometimes get undesired behaviour as, if you attempt to assign a value that does not match the type of the variable, nothing happens and as such the variable defaults to its
> default value.

## Inheritance

Your newly created type can define it's own logic by overriding `Entity` default classes, here is the list of them:

|function      |description| Return type|
|--------------|---------|-----------|
|_interact()   | What happens when the user interacts with this entity| None |
|_on_attacked() | What happens when the player attacks this entity | None|
|_talk() | What happens when the player talks to this entity| None|
|_die() | What happens when this entity dies| None |
|_get_loot() | How do you get the loot available from this entity| Dictionnary `{"item_id" : item_quantity}`|







