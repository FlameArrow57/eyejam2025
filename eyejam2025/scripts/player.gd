extends CharacterBody2D

@export var move_speed := 500
var canMove := true

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	Signals.RemovePlayerMovement.connect(removeMovement)
	Signals.AllowPlayerMovement.connect(allowMovement)

func _physics_process(_delta: float) -> void:
	if canMove:
		var move_vec := Input.get_vector("move_left","move_right","move_up","move_down")
		velocity = move_vec * move_speed
		move_and_slide()

	update_animation()

func update_animation() -> void:
	if velocity == Vector2.ZERO:
		anim.flip_h = false
		anim.play("idle")
		return

	if abs(velocity.x) > abs(velocity.y):
		anim.play("side")

		if velocity.x < 0:
			anim.flip_h = true
		else:
			anim.flip_h = false


	else:
		anim.flip_h = false 

		if velocity.y < 0:
			anim.play("up")
		else:
			anim.play("down")

func allowMovement() -> void:
	canMove = true

func removeMovement() -> void:
	canMove = false
	velocity = Vector2.ZERO
	anim.play("idle")
