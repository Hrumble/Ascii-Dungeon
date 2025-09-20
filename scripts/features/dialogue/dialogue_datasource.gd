class_name DialogueDatasource extends Node

var _pre_log : String = "DialogueDatasource> "
var dialogue_folder : String = "res://dialogues"

var dialogues : Dictionary = {}

signal dialogue_datasource_ready

## Initializes the dialogue datasource, without it, no dialogues are loaded
func initialize():
	Logger.log_i(_pre_log + "Initializing Dialogue Datasource...")
	load_dialogues()

## Returns a dialogue inside the `entity_name` folder called `dialogue_name`.json
func get_dialogue_by_name(entity_name : String, dialogue_name : String) -> Dialogue:
	if !dialogues.has(entity_name):
		Logger.log_e(_pre_log + "The dialogues for: " + entity_name + " does not exist! Are you sure you called DialogueDatasource.initialize()?")
		return null
	if !dialogues[entity_name].has(dialogue_name):
		Logger.log_e(_pre_log + "The dialogue called: " + dialogue_name + " does not exist!")
		return null
	return dialogues[entity_name][dialogue_name]

func get_random_dialogue_from(entity_name : String, starts_with : String = "") -> Dialogue:
	if !dialogues.has(entity_name):
		Logger.log_e(_pre_log + "The dialogues for: " + entity_name + " does not exist! Are you sure you called DialogueDatasource.initialize()?")
		return null
	# Gets all dialogues for the corresponding entity
	var keys : Array = dialogues[entity_name].keys()
	keys = keys.map(func(e): if (e as String).begins_with(starts_with): return e)
	# Gets the "id" of a random dialogue
	var random_key : String = keys[randi_range(0, keys.size() - 1)]
	var random_dialogue = dialogues[entity_name][random_key]
	return random_dialogue

# Preloads all the dialogues into memory, as I don't expect it to amount to 21gb
# If two dialogues are named the same, the second one takes priority, and the previous gets overwritten sowwy :3
func load_dialogues():	
	Logger.log_i(_pre_log + "Loading dialogues...")
	var dir : DirAccess = DirAccess.open(dialogue_folder)
	if !dir:
		Logger.log_e(_pre_log + "Could not open the dialogue folder: " + dialogue_folder)
		return
	# Gets all the 1st layer subdirectories
	# Which amount to entity names
	var entities_dir : Array[String] = []
	dir.list_dir_begin()
	var dir_name : String = dir.get_next()
	Logger.log_i(_pre_log + "Beginning recursive listing...")
	# This assumes all childer will be directories! if a file is found expect an error!
	while dir_name != "":
		entities_dir.append(dir_name)
		dir_name = dir.get_next()
	dir.list_dir_end()

	for entity_dir in entities_dir:
		var entity_dialogues_path : String = dialogue_folder + "/" + entity_dir
		var dialogue_dir = DirAccess.open(entity_dialogues_path)
		var entity_dialogues : Dictionary = {}
		dialogue_dir.list_dir_begin()
		var dialogue_name : String = dialogue_dir.get_next()
		while dialogue_name != "":
			var dialogue_path : String = entity_dialogues_path + "/" + dialogue_name
			# Star of the show, assigns to "my_dialogue" the dialogue object parsed from json
			var dialogue_object : Dialogue = Dialogue.fromJSON(FileAccess.get_file_as_string(dialogue_path))
			if dialogue_object == null:
				Logger.log_e(_pre_log + "Could not parse the json file: " + dialogue_path + ", skipping it...")
				dialogue_name = dialogue_dir.get_next()
				continue
			else:
				entity_dialogues[dialogue_name.get_basename()] = dialogue_object
				dialogue_name = dialogue_dir.get_next()
		# Adds all the dialogue objects to the main `dialogues` under the name of the folder
		Logger.log_i(_pre_log + "Successfully parsed dialogues for: " + entity_dir)
		dialogues[entity_dir] = entity_dialogues
	await get_tree().process_frame
	dialogue_datasource_ready.emit()





		
	
	

		
