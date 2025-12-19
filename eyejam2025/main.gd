extends Node2D

# game state
enum {STATE_START, STATE_MONSTER_PLANT, STATE_MONSTER_EYE, STATE_MONSTER_TEETH, STATE_MONSTER_FINAL}
var gameState = STATE_START
var dialogueActive := false

# interactibles
# bedroom
var bedAvailable := false
var eyeCollected := false
var eyeMonsterFed := false
var eyeMonsterMet := false
var catCollected := false
# main room
var frontDoorAnswerable := false
var plantMonsterFed := false
var plantMonsterMet := false
var armBleeding := false
var pillAvailable = false
@onready var initialKnockPos: Vector2 = $MainRoom/KnockEffect.position
var startKnockingEvent = true
var knockingEventActive = false
var knockInProgress = false
# kitchen
var teethMonsterFed := false
var teethMonsterMet := false

# sound effects
var openAncientBoxSound := preload("res://sound/ancient_box.ogg")
var eyeCutOutSound := preload("res://sound/cut_eye_out.ogg")
var cutArmSound := preload("res://sound/cut_arm.ogg")
var catMeowSound := preload("res://sound/cat_meow.ogg")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.InteractibleTriggered.connect(handleInteractible)
	Signals.TeleTriggered.connect(teleToRoom)
	Signals.DialogueStarted.connect(self.toggleDialogueActiveStatus)
	Signals.DialogueFinished.connect(self.toggleDialogueActiveStatus)
	
	# player set up
	$Player.position = $PlayerStart.position
	self.teleToRoom($PlayerStart, $Bedroom)
	
	# hide things
	# bedroom
	$Bedroom/EyeMonster.hide()
	# main room
	$MainRoom/Box.hide()
	$MainRoom/PlantMonster.hide()
	$MainRoom/KnockEffect.hide()
	# kitchen
	$Kitchen/TeethMonster.hide()
	$Kitchen/CombinedMonster.hide()
	
	$Ambience.play()
	
	await get_tree().create_timer(5).timeout
	if self.startKnockingEvent:
		self.knockingEventActive = true
	
func _process(_delta: float):
	if self.knockingEventActive and not self.knockInProgress:
		self.knockDoor()
	
func teleToRoom(playerMoveSpot: Marker2D, cameraFocusPoint: Sprite2D):
	$Player.position = playerMoveSpot.position
	$Camera2D.position = cameraFocusPoint.position + cameraFocusPoint.get_rect().size / 2
	$DialogueCreator.position = cameraFocusPoint.position + cameraFocusPoint.get_rect().size * Vector2(0.5, 0.75)
	$Foreground.position = cameraFocusPoint.position
	$Foreground.size = cameraFocusPoint.get_rect().size
	
func advanceGameState():
	match self.gameState:
		STATE_START:
			self.gameState = STATE_MONSTER_PLANT
		STATE_MONSTER_PLANT:
			self.gameState = STATE_MONSTER_EYE
		STATE_MONSTER_EYE:
			self.gameState = STATE_MONSTER_TEETH

func handleInteractible(intName: String):
	if self.dialogueActive:
		$DialogueCreator.startOrAdvDialogue("", "")
		return
	
	match intName:
		# bedroom
		"Bed":
			if self.bedAvailable:
				self.advanceGameState()
				
				Signals.RemovePlayerMovement.emit()
				Signals.RemovePlayerInteract.emit()
				await self.createOverlayColorFade(Color(0, 0, 0, 1), 3, 1)
				Signals.AllowPlayerMovement.emit()
				Signals.AllowPlayerInteract.emit()
				
				self.bedAvailable = false
				$DialogueCreator.startOrAdvDialogue("", "You lose control of your body and need to take another pill.")
				self.pillAvailable = true
			else:
				$DialogueCreator.startOrAdvDialogue("", "You don't feel like sleeping at this time.")
		"Cat":
			if self.gameState == STATE_MONSTER_TEETH and self.teethMonsterMet:
				$DialogueCreator.startOrAdvDialogue("", "You pick up the cat.")
				self.playSoundEffect(self.catMeowSound)
				self.catCollected = true
				await Signals.DialogueFinished
				$Bedroom/Cat.queue_free()
			else:
				$DialogueCreator.startOrAdvDialogue("", "The cat wakes up. She looks at you, stretches and then falls back asleep.")
		"Eye Monster":
			if self.eyeMonsterFed:
				$DialogueCreator.startOrAdvDialogue("", "watching...")
			elif not self.eyeCollected:
				$DialogueCreator.startOrAdvDialogue("", "blinded...")
				self.eyeMonsterMet = true
			else:
				$DialogueCreator.startOrAdvDialogue("", "You give the creature a new eye.")
				self.eyeMonsterFed = true
				await Signals.DialogueFinished
				$DialogueCreator.startOrAdvDialogue("", "I feel tired and should rest. That was exhausting.")
				self.bedAvailable = true
		# main room
		"Ancient Box":
			if self.pillAvailable:
				if self.gameState == STATE_MONSTER_EYE:
					$DialogueCreator.startOrAdvDialogue("", "You take a circular shaped pill and swallow it. You are able to take back control of your body.")
					$Bedroom/EyeMonster.show()
				elif self.gameState == STATE_MONSTER_TEETH:
					$DialogueCreator.startOrAdvDialogue("", "You take the star shaped pill and swallow it. You are able to take back control of your body.")
					$Kitchen/TeethMonster.show()
				self.playSoundEffect(self.openAncientBoxSound)
				self.pillAvailable = false
			else:
				if self.gameState == STATE_MONSTER_PLANT:
					$DialogueCreator.startOrAdvDialogue("", "There's a circular and a star shaped pill in the box. It smells of herbs and gives you a feeling you can't understand.")
				elif self.gameState == STATE_MONSTER_EYE:
					$DialogueCreator.startOrAdvDialogue("", "There's a star shaped pill in the box. It gives you a feeling you can't understand.")
				else:
					$DialogueCreator.startOrAdvDialogue("", "There's nothing in the box. It gives you a feeling you probably will never understand.")
		"Front Door":
			if self.gameState == STATE_START:
				self.startKnockingEvent = false
				self.knockingEventActive = false
				$DialogueCreator.startOrAdvDialogue("", "You answer the front door. No one is there, instead a package lies on the floor with a note on it: \"We cannot see, but we know. You can see, and you will know. Nurture it.\" Confused, you take the package inside and open it. A strange box is inside. A strange otherwordly feeling overwhelms your body. Not in control of yourself, you open up the box, which contains 3 pills, one squiggly shaped, one circular shaped, and the last star shaped. You then swallow the squiggly shaped pill.")
				await Signals.DialogueFinished
				self.playSoundEffect(self.openAncientBoxSound)
				$MainRoom/Box.show()
				self.advanceGameState()
				$MainRoom/PlantMonster.show()
				$MainRoom/PlantMonster.modulate.a = 0
				var tween := get_tree().create_tween()
				tween.tween_property($MainRoom/PlantMonster, "modulate:a", 1, 1)
			else:
				$DialogueCreator.startOrAdvDialogue("", "You want to open the front door, but your will to do so is gone.")
		"Plant Monster":
			if self.plantMonsterFed:
				$DialogueCreator.startOrAdvDialogue("", "satisfied...")
			elif not self.armBleeding:
				$DialogueCreator.startOrAdvDialogue("", "thirsty...")
				self.plantMonsterMet = true
			else:
				$DialogueCreator.startOrAdvDialogue("", "You squeeze blood from your arm onto the creature.")
				self.plantMonsterFed = true
				await Signals.DialogueFinished
				$DialogueCreator.startOrAdvDialogue("", "I feel tired and should rest. I can't tell if what I've seen is real or not. Hopefully it will go away when I wake up.")
				self.bedAvailable = true
		# kitchen
		"Knife":
			if self.gameState == STATE_MONSTER_PLANT and self.plantMonsterMet:
				if self.armBleeding:
					$DialogueCreator.startOrAdvDialogue("", "Using the knife wouldn't help any more at the moment.")
				else:
					$DialogueCreator.startOrAdvDialogue("", "You cut your arm with the knife and it is now bleeding. You feel there's no reason to attack the monster.")
					self.playSoundEffect(self.cutArmSound)
					self.armBleeding = true
			elif self.gameState == STATE_MONSTER_EYE and self.eyeMonsterMet:
				if self.eyeCollected:
					$DialogueCreator.startOrAdvDialogue("", "Using the knife wouldn't help any more at the moment.")	
				else:
					$DialogueCreator.startOrAdvDialogue("", "You cut your right eye out. There's no pain.")
					self.createOverlayColorFade(Color(1, 0, 0, 0.15), 0.75, 0.75)
					self.playSoundEffect(self.eyeCutOutSound)
					self.eyeCollected = true
			elif self.gameState == STATE_MONSTER_TEETH and self.teethMonsterMet:
				$DialogueCreator.startOrAdvDialogue("", "One limb would be too little. More limbs too demanding.")
			else:
				$DialogueCreator.startOrAdvDialogue("", "A sharp knife.")
		"Fridge":
			if self.gameState == STATE_MONSTER_TEETH or self.gameState == STATE_MONSTER_FINAL:
				$DialogueCreator.startOrAdvDialogue("", "The fridge is empty.")
			else:
				$DialogueCreator.startOrAdvDialogue("", "Nothing in the fridge interests you at the moment.")
		"Teeth Monster":
			if not self.catCollected:
				$DialogueCreator.startOrAdvDialogue("", "hungry...")
				self.teethMonsterMet = true
			else:
				$DialogueCreator.startOrAdvDialogue("", "You feed your cat to the creature. You feel nothing.")
				self.teethMonsterFed = true
				await Signals.DialogueFinished
				
				Signals.RemovePlayerMovement.emit()
				Signals.AllowPlayerInteract.emit()
				var tween = get_tree().create_tween()
				tween.tween_property($Kitchen/TeethMonster, "modulate:a", 0, 1)
				$Kitchen/TeethMonster.queue_free()
				$Kitchen/CombinedMonster.show()
				$Kitchen/CombinedMonster.modulate.a = 0
				tween.tween_property($Kitchen/CombinedMonster, "modulate:a", 1, 1)
				await tween.finished
				$DialogueCreator.startOrAdvDialogue("", "A larger horror appears, a combination of the earlier three. Yet I had no choice.")
				await Signals.DialogueFinished
				$DialogueCreator.startOrAdvDialogue("", "You perish from exhaustion.")
				await Signals.DialogueFinished
				self.createOverlayColorFade(Color(0, 0, 0, 1), 3, 1)
				await get_tree().create_timer(3).timeout
				self.teleToRoom($PlayerStart, $FinishPoint)
				
		"Balcony":
			if self.gameState == STATE_START:
				$DialogueCreator.startOrAdvDialogue("", "I have no interest in going onto the balcony right now.")
			else:
				$DialogueCreator.startOrAdvDialogue("", "I would go onto the balcony, but my will disappears when trying.")
		"Sink":
			if self.gameState == STATE_MONSTER_PLANT:
				if self.armBleeding:
					$DialogueCreator.startOrAdvDialogue("", "My arm will still bleed.")
				else:
					$DialogueCreator.startOrAdvDialogue("", "The creature seems like it is hydrated. Something tells me it's not looking for water.")
			elif self.eyeCollected and self.gameState == STATE_MONSTER_EYE:
				$DialogueCreator.startOrAdvDialogue("", "Water won't help me with my eye.")
			else:
				$DialogueCreator.startOrAdvDialogue("", "I don't have any use for water at the moment.")
		_:
			push_error("ERROR: Non-existing interactible ", intName, " being handled")

func knockDoor():
	self.knockInProgress = true
	$MainRoom/KnockEffect.show()
	for i in range(5):
		if not self.knockingEventActive:
			self.knockInProgress = false
			$MainRoom/KnockEffect.hide()
			return
		$MainRoom/KnockEffect.position = self.initialKnockPos + Vector2((randf() - 1) * 100, (randf() - 1) * 100)
		$MainRoom/KnockEffect.rotation_degrees = (1 if randi() % 2 == 0 else -1) * randf() * 30
		$MainRoom/KnockEffect/KnockSound.play()
		await get_tree().create_timer(0.3).timeout
	
	$MainRoom/KnockEffect.hide()
	
	await get_tree().create_timer(3).timeout
	self.knockInProgress = false

func toggleDialogueActiveStatus():
	self.dialogueActive = not self.dialogueActive

func createOverlayColorFade(col: Color, fadeInTime, fadeOutTime):
	$Foreground.show()
	$Foreground.modulate = col
	$Foreground.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.tween_property($Foreground, "modulate:a", col.a, fadeInTime)
	tween.tween_property($Foreground, "modulate:a", 0, fadeOutTime)
	await tween.finished
	$Foreground.hide()

func playSoundEffect(snd: AudioStream):
	$SoundEffects.stop()
	$SoundEffects.stream = snd
	$SoundEffects.play()
