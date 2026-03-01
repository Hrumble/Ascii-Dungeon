class_name FightEquipmentUI extends Control

@export var texture_rect: TextureRect
@export var animation_player: AnimationPlayer

@export var text_texture_rect: TextureRect
@export var text_label: RichTextLabel
@export var text_container: Control
@export var particles: GPUParticles2D

var origin_position: Vector2
var text_origin_position : Vector2


func _ready():
	text_origin_position = text_container.position
	text_container.hide()

## Plays the shake animation
func shake(speed_scale : float):
	animation_player.speed_scale = speed_scale
	animation_player.play("shake")


## Puts the item up (literally tweens y - 16), and returns the tween used for that
func step_up(time: float) -> Tween:
	var tween: Tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", position.y - 16, time)

	return tween


## Displays and animates the provided text, with the `texture` appearing to its left in a hboxcontainer
## returns the tween used for the animation
func shake_and_display_text(text: String, time: float, texture: Texture2D = null) -> Tween:
	text_container.show()

	text_label.text = "[center]%s[/center]" % text

	if texture == null:
		text_texture_rect.visible = false
	else:
		text_texture_rect.visible = true

	text_texture_rect.texture = texture
	text_container.modulate = Color(1, 1, 1, 0)

	var tween: Tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	particles.emitting = true
	tween.tween_property(text_container, "position:y", text_container.position.y - 32, time)
	shake(time * 2)
	tween.parallel().tween_property(text_container, "modulate:a", 1, time / 2)
	tween.tween_property(text_container, "modulate:a", 0, time / 2)

	return tween


## Resets the position of the equipment
func reset(time: float) -> Tween:
	var tween: Tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", origin_position.y, time)
	tween.parallel().tween_property(self, "modulate:a", 1, time)
	text_container.position = text_origin_position
	return tween


## Sets the texture of the item
func set_texture(texture: Texture2D):
	texture_rect.texture = texture
