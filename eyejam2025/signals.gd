extends Node

# player signals
signal PlayerInteractPressed
signal RemovePlayerMovement
signal AllowPlayerMovement

# area based triggers
signal InteractibleTriggered(intName: String)
signal TeleTriggered(teleToName: String, teleFromName: String)

# dialogue signals
var isDialogueActive = false
signal StartDialogue(triggerSource: String)
