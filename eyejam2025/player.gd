extends CharacterBody2D

@export var move_speed = 1000
var canMove = true
var footstepsAvailable = true

func _ready() -> void:
	Signals.RemovePlayerMovement.connect(removeMovement)
	Signals.AllowPlayerMovement.connect(allowMovement)
	
	$MoveSound.finished.connect(allowFootstepsSound)

func _physics_process(_delta: float) -> void:
	if self.canMove:
		var move_vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		self.velocity = move_vec * self.move_speed
		if move_vec != Vector2.ZERO and footstepsAvailable:
			$MoveSound.play()
			footstepsAvailable = false
		move_and_slide()
		
func allowMovement():
	self.canMove = true
	
func removeMovement():
	self.canMove = false

func allowFootstepsSound() -> void:
	await get_tree().create_timer(0.25).timeout
	self.footstepsAvailable = true
