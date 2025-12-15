extends CharacterBody2D

@export var move_speed = 1000
var canMove = true

func _ready() -> void:
	Signals.RemovePlayerMovement.connect(removeMovement)
	Signals.AllowPlayerMovement.connect(allowMovement)

func _physics_process(_delta: float) -> void:
	if self.canMove:
		var move_vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		self.velocity = move_vec * self.move_speed
		move_and_slide()
		
func allowMovement():
	self.canMove = true
	
func removeMovement():
	self.canMove = false
