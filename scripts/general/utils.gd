extends Node

const _pre_log : String = "Utils> "

## Provided an array of items and chances, it returns the winners of a chance contest, the provided arrays must be of the same size.
## Chance is between 0.0 and 1.0
## the `zip_array` is used if you need another array to undergo the exact same changes.
func pick_from_chance(item_ids : Array, item_chances : Array, zip_array = null):
	if zip_array != null and zip_array.size() < item_ids.size():
		Logger.log_e(_pre_log + "provided zip array is not the same size as item_chances!")
		return []

	if item_ids.size() != item_chances.size():
		Logger.log_e(_pre_log + "Chance constest: the two arrays are not of the same size!")
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
		Logger.log_e(_pre_log + "Weight contest: the two arrays are not of the same size!")
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
