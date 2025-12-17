extends Area2D

@export var teleTo: String
@export var teleFrom: String

func on_body_entered(body: Node2D):
	if body is CharacterBody2D:
		Signals.TeleTriggered.emit(self.teleTo, self.TeleFrom)
