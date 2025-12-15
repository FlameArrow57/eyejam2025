extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.StartDialogue.connect(handleDialogue)

func handleDialogue(triggerSource):
	match triggerSource:
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
