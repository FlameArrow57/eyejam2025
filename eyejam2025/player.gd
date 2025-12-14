extends CharacterBody2D

@export var move_speed = 1000

func _physics_process(delta: float) -> void:
	var move_vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	#var pos = move_vec * self.move_speed * delta

	#move_and_collide(pos)
	
	velocity = move_vec * self.move_speed
	move_and_slide()
