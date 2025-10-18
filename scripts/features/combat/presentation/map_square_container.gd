class_name MapSquareContainer extends PanelContainer


var is_hovering : bool = false
var map_position : Vector2i = Vector2i(0, 0)

func _ready():
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_hover_end)

func setup(_map_position : Vector2i):
	pass

func _on_hover():
	pass

func _on_hover_end():
	pass
