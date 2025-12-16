extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	
func createDialogue(speaker: String, speech: String):
	Signals.isDialogueActive = true
	self.visible = true
	Signals.RemovePlayerMovement.emit()
	
	$Speaker.text = speaker
	$Speech.text = ""
	
	for letter in speech:
		$Speech.text += letter
		$TypingSound.play()
		await get_tree().create_timer(0.1).timeout
	
	await get_tree().create_timer(2).timeout
	
	self.visible = false
	Signals.AllowPlayerMovement.emit()
	Signals.isDialogueActive = false
