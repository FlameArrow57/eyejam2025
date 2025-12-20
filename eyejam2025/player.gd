extends CharacterBody2D

@export var move_speed = 500
var canMove := true
var canInteract := true
var footstepsAvailable := true

@onready var anim := $AnimatedSprite2D

var eyeMissing := false:
	set(value):
		if self.anim.animation == &"down" or self.anim.animation == &"idle" or \
				(self.anim.animation == &"side" and self.anim.flip_h):
			self.anim.animation += "-eyeless"
		eyeMissing = value

func _ready() -> void:
	Signals.RemovePlayerMovement.connect(removeMovement)
	Signals.AllowPlayerMovement.connect(allowMovement)
	Signals.RemovePlayerInteract.connect(removeInteract)
	Signals.AllowPlayerInteract.connect(allowInteract)
	
	$MoveSound.finished.connect(allowFootstepsSound)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and self.canInteract:
		Signals.PlayerInteractPressed.emit()

func _physics_process(_delta: float) -> void:
	if self.canMove:
		var move_vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		self.velocity = move_vec * self.move_speed
		if move_vec != Vector2.ZERO and footstepsAvailable:
			$MoveSound.play()
			footstepsAvailable = false
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		move_and_slide()
		
	self.update_animation()

func update_animation() -> void:
	if velocity == Vector2.ZERO:
		anim.stop()
		return

	if abs(velocity.x) > abs(velocity.y):
		if velocity.x < 0:
			anim.play("side")
			anim.flip_h = false
		else:
			anim.play("side" if not self.eyeMissing else "side-eyeless")
			anim.flip_h = true
	else:
		anim.flip_h = false 

		if velocity.y < 0:
			anim.play("up")
		else:
			anim.play("down" if not self.eyeMissing else "down-eyeless")
		
func allowMovement():
	self.canMove = true
	
func removeMovement():
	self.canMove = false
	
func allowInteract():
	self.canInteract = true
	
func removeInteract():
	self.canInteract = false

func allowFootstepsSound() -> void:
	await get_tree().create_timer(0.25).timeout
	self.footstepsAvailable = true
