extends Control

var advanceDialogue = false
var finishDialogue = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	
func startOrAdvDialogue(speaker: String, speech: String):
	if not self.visible:
		self.createDialogue(speaker, speech)
	elif not self.advanceDialogue:
		self.advanceDialogue = true
	else:
		self.finishDialogue = true
	
func createDialogue(speaker: String, speech: String):
	self.visible = true
	Signals.RemovePlayerMovement.emit()
	
	$Speaker.text = speaker
	$Speech.text = ""
	
	var i = 0
	while not self.advanceDialogue and $Speech.text != speech:
		$Speech.text += speech[i]
		$TypingSound.play()
		await get_tree().create_timer(0.1).timeout
		i += 1
	
	if self.advanceDialogue:
		$Speech.text = speech
		
	self.advanceDialogue = true
	
	var finishTimer := get_tree().create_timer(2)
	while not self.finishDialogue and finishTimer.time_left > 0:
		await get_tree().create_timer(0.1).timeout
	
	self.visible = false
	self.advanceDialogue = false
	self.finishDialogue = false
	Signals.AllowPlayerMovement.emit()
