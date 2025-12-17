extends Node

# player signals
signal PlayerInteractPressed
signal RemovePlayerMovement
signal AllowPlayerMovement

# area based triggers
signal InteractibleTriggered(intName: String)
signal TeleTriggered(teleToName: String, teleFromName: String)

# dialogue signals
signal StartDialogue(triggerSource: String)
