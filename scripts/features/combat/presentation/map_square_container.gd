class_name MapSquareContainer extends PanelContainer


var is_hovering : bool = false

func _ready():
	mouse_entered.connect(on_hover)
	mouse_exited.connect(on_hover_end)

func on_hover():
	pass

func on_hover_end():
	pass
