class_name TooltipUI extends Control

@export var title_label : Label
@export var description_label : RichTextLabel

func open(title : String, description : String, _position : Vector2):
	title_label.text = title
	description_label.text = description
	position = _position
	show()

func close():
	hide()
