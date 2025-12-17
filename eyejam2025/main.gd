extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.InteractibleTriggered.connect(handleInteractible)
	Signals.TeleTriggered.connect(teleToRoom)
	
	self.teleToRoom("MainRoom", "")
	
func teleToRoom(newRoomName: String, oldRoomName: String):
	var roomNode: Sprite2D = get_node(newRoomName)
	$Camera2D.position = roomNode.position + roomNode.get_rect().size / 2
	
	if oldRoomName.length():
		pass

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
			$DialogueCreator.createDialogue("Test", "This is an ancient box")
