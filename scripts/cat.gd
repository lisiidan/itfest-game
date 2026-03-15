extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var accepted_reagent := "H2O"
var is_busy := false

func _ready() -> void:
	add_to_group("cat")
	play_sleep()

func play_sleep() -> void:
	is_busy = false
	animated_sprite.play("sleep")

func react_to_reagent(reagent_id: String) -> void:
	if is_busy:
		return

	if reagent_id == accepted_reagent:
		play_happy()
	else:
		play_angry()

func play_happy() -> void:
	is_busy = true
	animated_sprite.play("happy")
	await animated_sprite.animation_finished
	play_sleep()

func play_angry() -> void:
	is_busy = true

	var original_pos = position

	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color(1.4,0.5,0.5), 0.15)

	tween.tween_property(self, "position", original_pos + Vector2(-6,0), 0.05)
	tween.tween_property(self, "position", original_pos + Vector2(6,0), 0.05)
	tween.tween_property(self, "position", original_pos + Vector2(-4,0), 0.05)
	tween.tween_property(self, "position", original_pos + Vector2(4,0), 0.05)
	tween.tween_property(self, "position", original_pos, 0.05)

	animated_sprite.play("angry")

	await animated_sprite.animation_finished

	animated_sprite.modulate = Color.WHITE
	play_sleep()

func play_scared() -> void:
	is_busy = true
	animated_sprite.play("scared")
	await animated_sprite.animation_finished
	play_sleep()

func contains_point(point: Vector2) -> bool:
	return $CollisionShape2D.shape.get_rect().has_point(to_local(point))
