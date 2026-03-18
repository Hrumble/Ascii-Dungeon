class_name ItemUI extends PanelContainer

var item : Item:
	set(i):
		item = i
		_set_item()

var item_size : Vector2:
	set(_item_size):
		item_size = _item_size
		_set_item_size()

var item_texture : TextureRect
var item_rarity_texture : TextureRect


func _init():
	add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	item_rarity_texture = TextureRect.new()
	item_texture = TextureRect.new()

	item_texture.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	item_texture.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	add_child(item_rarity_texture)
	add_child(item_texture)


func _set_item():
	item_rarity_texture.texture = GlobalEnums.rarity_textures[item.rarity]
	item_texture.texture = item.texture

func _set_item_size():
	custom_minimum_size = item_size
	item_rarity_texture.custom_minimum_size = item_size
	item_texture.custom_minimum_size = item_size / 2
	pass
