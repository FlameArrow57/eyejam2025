extends Node2D

@export var interactArea: Area2D
@export var interactibleName: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.interactArea.body_entered.connect(self.on_body_entered)
	self.interactArea.body_exited.connect(self.on_body_exited)
	
	$Prompt.hide()
	
func _input(event: InputEvent) -> void:
	if event.is_action("interact") and not Signals.isDialogueActive and $Prompt.visible:
		Signals.StartDialogue.emit(self.interactibleName)
		pass
	
func on_body_entered(_body: Node2D):
	$Prompt.show()
	
func on_body_exited(_body: Node2D):
	$Prompt.hide()
