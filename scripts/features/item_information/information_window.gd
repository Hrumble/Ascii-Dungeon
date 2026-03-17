class_name ItemInformationWindow extends Control

@export var item_name_label : Label
@export var item_rarity_label : Label
@export var item_description_label : Label
@export var container : Control

var item_ui : ItemUI

func _ready():
	item_ui = ItemUI.new()
	item_ui.item_size = Vector2(100, 100)
	container.add_child(item_ui)
	container.move_child(item_ui, 0)

func open(item : Item):
	item_name_label.text = item.display_name
	item_description_label.text = item.description
	item_rarity_label.text = GlobalEnums.rarity_names[item.rarity]
	item_rarity_label.modulate = GlobalEnums.rarity_colors[item.rarity]
	item_ui.item = item


func close():
	hide()
