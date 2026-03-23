extends Node

@onready var bgm: AudioStreamPlayer2D = $BGM

func _ready() -> void:
	if not bgm.playing:
		bgm.play()
