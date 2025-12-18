extends Area2D

@export var teleToMarker: Marker2D
@export var cameraFocusPoint: Sprite2D

func _ready() -> void:
	self.body_entered.connect(self.on_body_entered)

func on_body_entered(body: Node2D):
	if body is CharacterBody2D:
		Signals.TeleTriggered.emit(self.teleToMarker, self.cameraFocusPoint)
