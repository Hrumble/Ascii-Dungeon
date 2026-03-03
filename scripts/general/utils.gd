extends Node

const _pre_log : String = "Utils> "

## Provided an array of items and chances, it returns the winners of a chance contest, the provided arrays must be of the same size.
## Chance is between 0.0 and 1.0
## the `zip_array` is used if you need another array to undergo the exact same changes.
func pick_from_chance(item_ids : Array, item_chances : Array, zip_array = null):
	if zip_array != null and zip_array.size() < item_ids.size():
		GlobalLogger.log_e(_pre_log + "provided zip array is not the same size as item_chances!")
		return []

	if item_ids.size() != item_chances.size():
		GlobalLogger.log_e(_pre_log + "Chance constest: the two arrays are not of the same size!")
		return []

	var zipped = []
	var qualified_ids = []
	for i in item_ids.size():
		if roll_chance(item_chances[i]):
			qualified_ids.append(item_ids[i])
			if !zip_array == null:
				zipped.append(zip_array[i])

	if zip_array != null:
		# array needs to be modified in place to modify reference
		zip_array.clear()
		zip_array.append_array(zipped)

	return qualified_ids

## Provided an array of items and weights, it returns the winners of a weight contest, the provided arrays must be of the same size.
func pick_from_weight(item_ids : Array, item_weights : Array):
	if item_ids.size() != item_weights.size():
		GlobalLogger.log_e(_pre_log + "Weight contest: the two arrays are not of the same size!")
		return []

	var total_weight : float = 0.0
	for i in item_ids.size():
		total_weight += item_weights[i]

	var r = randf() * total_weight

	var cumulative_weight : float = 0.0
	for i in item_ids.size():
		if cumulative_weight <= r:
			return item_ids[i]
		cumulative_weight += item_weights[i]

## Rolls a number, if lower than probability returns true, else false
## Probability must be between 0.0 and 1.0
func roll_chance(probability : float) -> bool:
	return randf() <= probability

## Returns a random number between `min` and `max`, higher chance to get lower numbers. you can change the `bias` to favor odds
func skewed_random_distribution(min : int, max : int, bias : float = 2.0) -> int:
	return min + int(pow(randf(), bias) * (max - min))

#--------------------------------------------------------------------#
#                                 UI                                 #
#--------------------------------------------------------------------#

## Returns the correct position for this node to be centered on itself since godot doesn't HAVE A FUCKING BUILT IN WAY TO DO THAT
func anchor_center(control : Control, pos : Vector2):
	return pos - Vector2(control.getsize/2, control.size.y/2)

#--------------------------------------------------------------------#
#                             Enum Utils                             #
#--------------------------------------------------------------------#

## Matches `str` to its corresponding rarity, returns [GlobalEnums.Rarity.COMMON] if there is no match
func string_to_rarity(v : String) -> GlobalEnums.RARITY:
	v = v.to_upper()
	match v:
		"COMMON":
			return GlobalEnums.RARITY.COMMON
		"UNCOMMON":
			return GlobalEnums.RARITY.UNCOMMON
		"RARE":
			return GlobalEnums.RARITY.RARE
		"INSANELY_RARE":
			return GlobalEnums.RARITY.INSANELY_RARE
		"UNHEARD":
			return GlobalEnums.RARITY.UNHEARD
		_ :
			return GlobalEnums.RARITY.COMMON

## Matches `str` to its corresponding equipment slot, returns [GlobalEnums.EQUIPMENT_SLOTS.R_HAND] if there is no match
func string_to_equipment_slot(v : String) -> GlobalEnums.EQUIPMENT_SLOTS:
	v = v.to_upper()
	match v:
		"HEAD":
			return GlobalEnums.EQUIPMENT_SLOTS.HEAD
		"R_HAND":
			return GlobalEnums.EQUIPMENT_SLOTS.R_HAND
		"L_HAND":
			return GlobalEnums.EQUIPMENT_SLOTS.L_HAND
		"CHEST":
			return GlobalEnums.EQUIPMENT_SLOTS.CHEST
		"LEGS":
			return GlobalEnums.EQUIPMENT_SLOTS.LEGS
		"FEET":
			return GlobalEnums.EQUIPMENT_SLOTS.FEET
		"R_FINGER_0":
			return GlobalEnums.EQUIPMENT_SLOTS.R_FINGER_0
		"R_FINGER_1":
			return GlobalEnums.EQUIPMENT_SLOTS.R_FINGER_1
		"L_FINGER_0":
			return GlobalEnums.EQUIPMENT_SLOTS.L_FINGER_0
		"L_FINGER_1":
			return GlobalEnums.EQUIPMENT_SLOTS.L_FINGER_1
		_:
			return GlobalEnums.EQUIPMENT_SLOTS.R_HAND
