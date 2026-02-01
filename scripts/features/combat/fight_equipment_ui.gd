class_name FightEquipmentUI extends Control

@export var texture_rect : TextureRect
@export var animation_player : AnimationPlayer

@export var text_texture_rect : TextureRect
@export var text_label : RichTextLabel
@export var text_container : Control
@export var particles : GPUParticles2D

func _ready():
	text_container.hide()

## Plays the shake animation
func shake():
	animation_player.play("shake")

## Puts the item up (literally tweens y - 16), and returns the tween used for that
func step_up(time : float = .5) -> Tween:
	var tween : Tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", position.y - 16, time)

	return tween

## Displays and animates the provided text, with the `texture` appearing to its left in a hboxcontainer
## returns the tween used for the animation
func shake_and_display_text(text : String, texture : Texture2D = null, time : float = .5) -> Tween:
	text_container.show()

	text_label.text = "[center]%s[/center]" % text

	if texture == null:
		text_texture_rect.visible = false
	else:
		text_texture_rect.visible = true

	text_texture_rect.texture = texture
	text_container.modulate = Color(1, 1, 1, 0)

	var tween : Tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	particles.emitting = true
	tween.tween_property(text_container, "position:y", text_container.position.y - 32, time)
	shake()
	tween.parallel().tween_property(text_container, "modulate:a", 1, time)
	tween.tween_property(text_container, "modulate:a", 0, time)

	return tween

## Sets the texture of the item
func set_texture(texture : Texture2D):
	texture_rect.texture = texture
