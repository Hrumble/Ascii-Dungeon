class_name FightContext extends Node

## The current instantiated enemy
var enemy : Entity = null
## The current player
var player : PlayerManager = null
## The intent of the enemy on this turn
var enemy_intent : FightIntent = null
## The move of the enemy on this turn
var enemy_move : FightMove = null
## Wether or not the player blocks
var block_success : bool = false
## The count of the current turn
var turn_count : int = 0
## The current fight going on
var fight : Fight
## Arbitrary custom fight data
var flags : Dictionary = {}
