extends Node

const _pre_log : String = "Utils> "

## Provided an array of items and chances, it returns the winners of a chance contest, the provided arrays must be of the same size.
## Chance is between 0.0 and 1.0
func pick_from_chance(item_ids : Array, item_chances : Array):
	if item_ids.size() != item_chances.size():
		Logger.log_e(_pre_log + "Chance constest: the two arrays are not of the same size!")
		return []

	var qualified_ids = []
	for i in item_ids.size():
		if roll_chance(item_chances[i]):
			qualified_ids.append(item_ids[i])
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
