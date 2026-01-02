class_name DialogueWindow extends Control

@export var texture_rect : TextureRect
@export var name_label : RichTextLabel
@export var dialogue_label : RichTextLabel
@export var next_button : Button

var _dialogue_manager : DialogueManager
var _registry : Registry
const _PRE_LOG : String = "DialogueWindow> "

func _ready():
	_dialogue_manager = GameManager.get_dialogue_manager()
	_registry = GameManager.get_registry()

	## Connections
	_dialogue_manager.dialogue_next_object.connect(_on_next_object)
	_dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)
	next_button.pressed.connect(_on_next_pressed)


#--------------------------------------------------------------------#
#                         Dialogue Handling                          #
#--------------------------------------------------------------------#
	
## Updates the text of the new object
func _on_next_object():
	_display_text()

func _on_dialogue_ended():
	close()

## Typewriter effect because i love it
func _display_text():
	var text : String = _dialogue_manager.current_object.text
	dialogue_label.text = text
	dialogue_label.visible_characters = 0
	for c in text.length():
		if c <= 0:
			dialogue_label.visible_characters += 1
			continue

		if text[c-1] in ".,!?:;":
			await get_tree().create_timer(.2).timeout
		else:
			await  get_tree().create_timer(.01).timeout

		dialogue_label.visible_characters += 1

#--------------------------------------------------------------------#
#                          Window Handling                           #
#--------------------------------------------------------------------#

func _on_next_pressed():
	_dialogue_manager.next_object()
	pass

func open():
	print("ok")
	if _dialogue_manager.current_dialogue == null:
		GlobalLogger.log_w(_PRE_LOG + "Attempted to open the dialogue manager, but there is no ongoing dialogue")
		return

	var entity_id : String = _dialogue_manager.current_dialogue.dialogue_entity_id

	var entity : Entity = _registry.get_entry_by_id(entity_id)
	if entity == null:
		GlobalLogger.log_e(_PRE_LOG + "Could not find the corresponding entity for %s, cannot display image" % entity_id)
	else:
		if entity.texture != null:
			texture_rect.texture = entity.texture
	
	name_label.text = entity.get_display_name()
	# _dialogue_manager.next_object()
	dialogue_label.text = _dialogue_manager.current_object.text

	show()


func close():
	hide()
	pass
