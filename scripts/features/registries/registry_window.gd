class_name RegistryWindow extends Control

@export var search_bar : LineEdit
@export var filter_button : Button
@export var results_container : Control
@export var no_result_label : Label
@export var registry_result_scene : PackedScene

var _registry : Registry
var prev_results : Array[Object]

func _ready():
	_registry = GameManager.get_registry()

	search_bar.text_changed.connect(_on_search_changed)
	_on_search_changed("")

func open():
	show()

func close():
	hide()

#--------------------------------------------------------------------#
#                              Handlers                              #
#--------------------------------------------------------------------#

## When the text on the search bar changes
func _on_search_changed(text : String):
	# If no text, return everything
	if (text.is_empty()):
		_display_results(_registry.get_all_entries())
		return

	var results : Array[Object] = _registry.search_entries(text)
	# No need to rebuild if it's the same results
	if prev_results == results:
		return
	else:
		_display_results(results)
		prev_results = results


func _display_results(results : Array[Object]):
	_clear_results()

	if results.is_empty():
		no_result_label.show()
		return
	else:
		no_result_label.hide()

	for res in results:
		print("Found %s" % res.id)
		var registry_result : RegistryResultUI = registry_result_scene.instantiate()

		registry_result.setup(res)

		results_container.add_child(registry_result)


func _clear_results():
	for c in results_container.get_children():
		c.queue_free()
