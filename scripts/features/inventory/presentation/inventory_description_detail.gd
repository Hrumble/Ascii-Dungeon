class_name InventoryDescriptionUI extends Control

@export var _item_name_label : Label
@export var _item_description_label : RichTextLabel

func set_text(title : String, description : String):
	_item_name_label.text = title
	_item_description_label.text = description

