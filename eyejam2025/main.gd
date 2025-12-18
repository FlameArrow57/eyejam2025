extends Node2D

# start, 
# phase 1 - 
enum {STATE_START}

var gameState = STATE_START

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.InteractibleTriggered.connect(handleInteractible)
	Signals.TeleTriggered.connect(teleToRoom)
	
	$Player.position = $PlayerStart.position
	
	self.teleToRoom($PlayerStart, $Bedroom)
	
func teleToRoom(playerMoveSpot: Marker2D, cameraFocusPoint: Sprite2D):
	$Player.position = playerMoveSpot.position
	$Camera2D.position = cameraFocusPoint.position + cameraFocusPoint.get_rect().size / 2

func handleInteractible(intName: String):
	match intName:
		"Bed":
			pass
		"Ancient box":
			pass
		"Front door":
			pass
		"Knife":
			pass
		"TV":
			pass
		_:
			$DialogueCreator.startOrAdvDialogue("Test", "This is an ancient box")
