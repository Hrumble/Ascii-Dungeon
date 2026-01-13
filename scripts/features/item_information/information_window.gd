class_name ItemInformationWindow extends Control

@export var item_name_label : Label
@export var item_rarity_label : Label
@export var item_description_label : Label
@export var item_texture_rect : TextureRect

func open(item : Item):
	item_name_label.text = item.display_name
	item_description_label.text = item.description
	item_rarity_label.text = "Rarity: %s" % GlobalEnums.rarity_names[item.rarity]
	item_rarity_label.modulate = GlobalEnums.rarity_colors[item.rarity]
	item_texture_rect.texture = item.texture

	show()

func close():
	hide()
