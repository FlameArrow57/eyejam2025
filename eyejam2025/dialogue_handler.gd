extends Control

@onready var initialBackgroundSize = $ColorRect.size
@onready var lastTextBoxSize = $ColorRect/Speech.size

var advanceDialogue = false
var finishDialogue = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	
	$ColorRect/Speech.resized.connect(self.increaseBackgroundSize)
	
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
	Signals.DialogueStarted.emit()
	
	$ColorRect/Speaker.text = speaker
	$ColorRect/Speech.text = ""
	
	var i = 0
	while not self.advanceDialogue and $ColorRect/Speech.text != speech:
		$ColorRect/Speech.text += speech[i]
		if i % 2 == 0:
			$TypingSound.play()
		await get_tree().create_timer(0.05).timeout
		i += 1
	
	if self.advanceDialogue:
		$ColorRect/Speech.text = speech
		
	self.advanceDialogue = true
	
	var finishTimer := get_tree().create_timer(2 + 0.05 * speech.length())
	while not self.finishDialogue and finishTimer.time_left > 0:
		await get_tree().create_timer(0.1).timeout
	
	self.visible = false
	self.advanceDialogue = false
	self.finishDialogue = false
	$ColorRect.size = initialBackgroundSize
	Signals.AllowPlayerMovement.emit()
	Signals.DialogueFinished.emit()
	
func increaseBackgroundSize():
	$ColorRect.size += $ColorRect/Speech.size - self.lastTextBoxSize
	self.lastTextBoxSize = $ColorRect/Speech.size
