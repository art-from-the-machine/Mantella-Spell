Scriptname MantellaMCM extends SKI_ConfigBase 

;don't forget to set this in the CK!
MantellaRepository property repository auto

int property oid_microphoneEnabledToggle auto
int property oid_responsetimeslider auto

int property oid_keymapStartAddHotkey auto
int property oid_keymapPromptHotkey auto
int property oid_keymapEndHotkey auto
int property oid_keymapCustomGameEventHotkey auto
int property oid_keymapRadiantHotkey auto

int property oid_showDialogueItems auto

int property oid_radiantenabled auto
int property oid_radiantdistance auto
int property oid_radiantfrequency auto


int property oid_playerTrackingUsePCName auto
int property oid_playerTrackingOnItemAdded auto
int property oid_playerTrackingOnItemRemoved auto
int property oid_playerTrackingOnSpellCast auto
int property oid_playerTrackingOnHit auto
int property oid_playerTrackingOnLocationChange auto
int property oid_playerTrackingOnObjectEquipped auto
int property oid_playerTrackingOnObjectUnequipped auto
int property oid_playerTrackingOnPlayerBowShot auto
int property oid_playerTrackingOnSit auto
int property oid_playerTrackingOnGetUp auto
int property oid_playerTrackingAll auto
bool property playerAllToggle auto


int property oid_targetTrackingItemAddedToggle auto
int property oid_targetTrackingItemRemovedToggle auto
int property oid_targetTrackingOnSpellCastToggle auto
int property oid_targetTrackingOnHitToggle auto
int property oid_targetTrackingOnCombatStateChangedToggle auto
int property oid_targetTrackingOnObjectEquippedToggle auto
int property oid_targetTrackingOnObjectUnequippedToggle auto
int property oid_targetTrackingOnSitToggle auto
int property oid_targetTrackingOnGetUpToggle auto
int property oid_targetTrackingOnDyingToggle auto
int property oid_targetTrackingAll auto
bool property targetAllToggle auto


int property oid_AllowForNPCtoFollowToggle auto ;gia
int property oid_NPCAngerToggle auto ;gia
int property oid_NPCPackageToggle auto

int property oid_debugNPCSelectMode auto
int property oid_httpPort auto


;Vision properties
int property oid_automaticVisionAnalysis auto
int property oid_SteamVisionAnalysis auto
int property oid_visionResolution auto
int property oid_hideInterfaceDuringScreenshot auto
int property oid_keymapVisionHotkey auto
int property oid_resize auto
string[] property resolutionMenuList auto
int property resolutionMenuDefaultIndex auto

string MantellaMCMcurrentPage

Event OnConfigInit()
	;this part right here name all the pages we'll need (we can add more pages at the end as long as we update the numbers) and declares some variables
    ModName = "Mantella"
	Pages = new string[5]
    Pages[0] = "General"
	Pages[1] = "Player Tracking"
	Pages[2] = "Target Tracking"
 	Pages[3] = "Advanced"
	Pages[4] = "Vision"
 
	targetAllToggle=true
	playerAllToggle=true

	resolutionMenuList = new string[3]
	resolutionMenuList[0] = "auto"
	resolutionMenuList[1] = "high"
	resolutionMenuList[2] = "low"
    resolutionMenuDefaultIndex = 1

EndEvent

Event OnPageReset(string page)
	;this is the event that triggers when the pages get clicked, so I link to the other MCM scripts that are basically just used for global functions
	if page==""
		loadcustomcontent("Mantella/splash.dds")
		MantellaMCMcurrentPage="Intro"
	else 
		unloadcustomcontent()
	endif
	if page=="General"
		MantellaMCM_GeneralSettings.Render(self, repository)
		MantellaMCMcurrentPage="General"
	elseif page=="Player Tracking"
		MantellaMCM_PlayerTrackingSettings.Render(self, repository)
		MantellaMCMcurrentPage="Player Tracking"
	elseif page=="Target Tracking"
		MantellaMCM_TargetTrackingSettings.Render(self, repository)
		MantellaMCMcurrentPage="Target Tracking"
	elseif page=="Advanced"
		MantellaMCM_AdvancedSettings.Render(self, repository)
		MantellaMCMcurrentPage="Advanced"
 	elseif page=="Vision"
		MantellaMCM_VisionSettings.Render(self, repository)
		MantellaMCMcurrentPage="Vision"
	endif		
EndEvent

;This part of the MCM below is a bunch of event listeners, they all use functions to link to the appropriate MCM scripts 
Event OnOptionSelect(int optionID)
	if MantellaMCMcurrentPage =="General"
		MantellaMCM_GeneralSettings.OptionUpdate(self,optionID, repository)	
	elseif MantellaMCMcurrentPage =="Player Tracking"
		MantellaMCM_PlayerTrackingSettings.OptionUpdate(self,optionID, repository)	
	elseif MantellaMCMcurrentPage =="Target Tracking"
		MantellaMCM_TargetTrackingSettings.OptionUpdate(self,optionID, repository)	
	elseif MantellaMCMcurrentPage =="Advanced"
		MantellaMCM_AdvancedSettings.OptionUpdate(self,optionID, repository)
	elseif MantellaMCMcurrentPage =="Vision"
		MantellaMCM_VisionSettings.OptionUpdate(self,optionID, repository)	
	endif
EndEvent 

Event OnOptionSliderOpen(Int optionId)
    If MantellaMCMcurrentPage =="General"
		MantellaMCM_GeneralSettings.SliderOptionOpen(self,optionID, repository)
	elseif MantellaMCMcurrentPage =="Vision"
		MantellaMCM_VisionSettings.SliderOptionOpen(self,optionID, repository)	
    EndIf
EndEvent

Event OnOptionSliderAccept(Int optionId, Float value)
	If MantellaMCMcurrentPage =="General"
		MantellaMCM_GeneralSettings.SliderOptionAccept(self,optionID, value, repository)
	elseif MantellaMCMcurrentPage =="Vision"
		MantellaMCM_VisionSettings.SliderOptionAccept(self,optionID, value, repository)
    EndIf
EndEvent

Event OnOptionKeyMapChange(Int a_option, Int a_keyCode, String a_conflictControl, String a_conflictName)
    {Called when a key has been remapped}
    If 	MantellaMCMcurrentPage =="General"
		MantellaMCM_GeneralSettings.KeyMapChange(self,a_option, a_keyCode, a_conflictControl, a_conflictName, repository)
	elseif MantellaMCMcurrentPage =="Vision"
		MantellaMCM_VisionSettings.KeyMapChange(self,a_option, a_keyCode, a_conflictControl, a_conflictName, repository)
	EndIf
EndEvent

event OnOptionInputAccept(int optionID, string inputText)
	if MantellaMCMcurrentPage =="Advanced"
		MantellaMCM_AdvancedSettings.OptionInputUpdate(self, optionID, inputText, repository)
	endif
EndEvent

event OnOptionMenuOpen(int optionID)
	if MantellaMCMcurrentPage =="Vision"
		MantellaMCM_VisionSettings.OptionInputMenuOpen(self, optionID, resolutionMenuList, resolutionMenuDefaultIndex, repository)
	endif
endEvent

event OnOptionMenuAccept(int optionID, int indexID)
	if MantellaMCMcurrentPage =="Vision"
		MantellaMCM_VisionSettings.OptionInputMenuAccept(self, optionID, indexID, repository)
	endif
endEvent

Event OnOptionHighlight (Int optionID)
	if optionID == oid_microphoneEnabledToggle	
		SetInfoText("Toggles microphone / text input (requires Mantella.exe restart). \nThis setting overrides the `microphone_enabled` option in MantellaSoftware/config.ini.")
	elseIf optionID == oid_responsetimeslider
		SetInfoText("Time (in seconds) to enter a text response (microphone disabled only). \nDefault: 180")
    
    elseIf optionID == oid_keymapStartAddHotkey
		SetInfoText("Either starts a conversation or adds an NPC to a conversation.")
	elseIf optionID == oid_keymapPromptHotkey
		SetInfoText("Opens the text prompt, depending on the context. \nDefault: H")
	elseIf optionID == oid_keymapEndHotkey
		SetInfoText("Ends all Mantella conversations.")
	elseIf optionID == oid_keymapCustomGameEventHotkey	
		SetInfoText("Opens a text prompt to enter a custom game event (eg 'The house is on fire').")
	elseIf optionID == oid_keymapRadiantHotkey	
		SetInfoText("Toggle radiant conversations.")

    elseIf optionID == oid_showDialogueItems	
		SetInfoText("Show the dialogue tree entries to start a conversation or add and remove NPCs from it.")

	elseIf optionID == oid_radiantenabled
		SetInfoText("Starts a Mantella conversation between the nearest two NPCs to the player at a given frequency. \nNPCs must both be stationary when a radiant dialogue attempt is made.")
	elseIf optionID == oid_radiantdistance
		SetInfoText("How far from the player (in meters) radiant dialogues can begin. \nDefault: 20")
	elseIf optionID == oid_radiantfrequency
		SetInfoText("How frequently (in seconds) radiant dialogues should attempt to begin. \nDefault: 10")

	
    elseIf optionID == oid_playerTrackingUsePCName	
		SetInfoText("Use the name of the player character when tracking events. Uses 'Player' otherwise.")
	elseIf optionID == oid_playerTrackingOnItemAdded	
		SetInfoText("Tracks items picked up / acquired while a Mantella conversation is active.")
	elseIf optionID == oid_playerTrackingOnItemRemoved	
		SetInfoText("Tracks items dropped / removed while a Mantella conversation is active.")
	elseIf optionID == oid_playerTrackingOnSpellCast	
		SetInfoText("Tracks spells / shouts / effects casted while a Mantella conversation is active.")
	elseIf optionID == oid_playerTrackingOnHit	
		SetInfoText("Tracks damage taken (and the source of the damage) while a Mantella conversation is active.")
	elseIf optionID == oid_playerTrackingOnLocationChange	
		SetInfoText("Tracks location changes while a Mantella conversation is active.")
	elseIf optionID == oid_playerTrackingOnObjectEquipped	
		SetInfoText("Tracks items / spells / shouts equipped while a Mantella conversation is active.")
	elseIf optionID == oid_playerTrackingOnObjectEquipped	
		SetInfoText("Tracks items / spells / shouts unequipped while a Mantella conversation is active.")
	elseIf optionID == oid_playerTrackingOnPlayerBowShot	
		SetInfoText("Tracks if player shoots an arrow while a Mantella conversation is active.")
	elseIf optionID == oid_playerTrackingOnSit
		SetInfoText("Tracks furniture rested on while a Mantella conversation is active.")
	elseIf optionID == oid_playerTrackingOnGetUp
		SetInfoText("Tracks furniture stood up from while a Mantella conversation is active.")
	elseIf optionID == oid_playerTrackingAll	
		SetInfoText("Enable / disable all tracking options for the player.")
	
	
	elseIf optionID == oid_targetTrackingItemAddedToggle	
		SetInfoText("Tracks items picked up / acquired while a Mantella conversation is active.")
	elseIf optionID == oid_targetTrackingItemRemovedToggle	
		SetInfoText("Tracks items dropped / removed while a Mantella conversation is active.")
	elseIf optionID == oid_targetTrackingOnSpellCastToggle	
		SetInfoText("Tracks spells / shouts / effects casted while a Mantella conversation is active.")
	elseIf optionID == oid_targetTrackingOnHitToggle	
		SetInfoText("Tracks damage taken (and the source of the damage) while a Mantella conversation is active.")
	elseIf optionID == oid_targetTrackingOnCombatStateChangedToggle	
		SetInfoText("Tracks combat state changes while a Mantella conversation is active.")
	elseIf optionID == oid_targetTrackingOnObjectEquippedToggle	
		SetInfoText("Tracks items / spells / shouts equipped while a Mantella conversation is active.")
	elseIf optionID == oid_targetTrackingOnObjectUnequippedToggle	
		SetInfoText("Tracks items / spells / shouts unequipped while a Mantella conversation is active.")
	elseIf optionID == oid_targetTrackingOnSitToggle	
		SetInfoText("Tracks furniture rested on while a Mantella conversation is active.")
	elseIf optionID == oid_targetTrackingOnGetUpToggle	
		SetInfoText("Tracks furniture stood up from while a Mantella conversation is active.")
	elseIf optionID == oid_targetTrackingOnGetUpToggle	
		SetInfoText("Enable / disable all tracking options for the target.")


	elseIf optionID == oid_AllowForNPCtoFollowToggle ;gia
		SetInfoText("NPCs can be convinced to follow (not tested over long playthroughs).")
	elseIf optionID == oid_NPCAngerToggle ;gia
		SetInfoText("NPCs can attack the player if provoked.")
	elseIf optionID == oid_NPCPackageToggle
		SetInfoText("NPCs will stop to talk to you and will not engage in non-Mantella conversations.")

	elseIf optionID == oid_debugNPCSelectMode
		SetInfoText("Allows the player to speak to any NPC by initiating a conversation then entering the actor RefID and actor name that the player wishes to speak to")
	elseif optionID == oid_httpPort
		SetInfoText("HTTP port for Mantella to call. If you need to change the default port, change it here and the port for MantellaSoftware's server in its config.ini. Default: 4999")
	
	elseIf optionID == oid_automaticVisionAnalysis
		SetInfoText("Toggle this option to enable automatic vision analysis. A screenshot of the player's vision will be sent automatically with each reply to the AI (LLM)")
	elseIf optionID == oid_SteamVisionAnalysis
		SetInfoText("Toggle this option to enable vision analysis. A screenshot must be taken using the Steam Interface (usually left trigger + left menu button) and will be sent to the LLM on the next reply (must be sent within 2 minutes)")
	elseif optionID == oid_visionResolution
		SetInfoText("Select this option to choose the resolution of the screenshots sent to the AI. Lower it to reduce token use and reponse generation time.")
	elseif optionID == oid_hideInterfaceDuringScreenshot
		SetInfoText("Select this option to hide the HUD when screenshots are captured by Mantella to avoid confusing the AI or reduce the chance of it breaking character")
	elseif optionID == oid_keymapVisionHotkey
		SetInfoText("Use this hotkey to take a screenshot that will be later sent to the the AI on your next reply")	
	elseif optionID == oid_resize
		SetInfoText("Lower this value to resize the image (width in pixels) before sending it to the LLM to accelerate response time and diminish token use (recommended minimum : 512, recommended maximum : 2000). If a value greater than the actual screen resolution is used, Mantella Software will default to the actual screen resolution value.")	
	EndIf
endEvent

