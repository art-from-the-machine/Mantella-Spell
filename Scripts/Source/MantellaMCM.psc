Scriptname MantellaMCM extends SKI_ConfigBase 

;don't forget to set this in the CK!
MantellaRepository property repository auto

;bool property microphoneEnabledToggle auto
;int property responsetimer auto
;string property mcmActorName auto

;oid variables are pretty much just int values to link to the correct button when displaying info with render functions
int property oid_responsetimeslider auto
int property oid_keymapPromptHotkey auto
int property oid_keymapCustomGameEventHotkey auto
int property oid_microphoneEnabledToggle auto
int property oid_debugNPCSelectMode auto

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


;not tracking dying triggers they're only there as a check to end the conversation
;bool property targetTrackingOnDyingToggle auto

;this toggle below is used in the TargetTrackingSettings
bool property targetAllToggle auto

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

;this toggle below is used in the PlayerTrackingSettings
bool property playerAllToggle auto

int property oid_radiantenabled auto
int property oid_radiantdistance auto
int property oid_radiantfrequency auto

string MantellaMCMcurrentPage

Event OnConfigInit()
	;this part right here name all the pages we'll need (we can add more pages at the end as long as we update the numbers) and declares some variables
    ModName = "Mantella"
	Pages = new string[4]
    Pages[0] = "Main settings"
	Pages[1] = "Player tracking settings"
	Pages[2] = "Target tracking settings"
	Pages[3] = "Radiant Dialogue"
 
	;not tracking dying triggers they're only there as a check to end the conversation
	;targetTrackingOnDyingToggle=true
	targetAllToggle=true
	playerAllToggle=true

EndEvent
Event OnPageReset(string page)
	;this is the event that triggers when the pages get clicked, so I link to the other MCM scripts that are basically just used for global functions
	if page==""
		loadcustomcontent("Mantella/splash.dds")
		MantellaMCMcurrentPage="Intro"
	else 
		unloadcustomcontent()
	endif
	if page=="Main settings"
		MantellaMCM_MainSettings.Render(self, repository)
		MantellaMCMcurrentPage="Main settings"
	elseif page=="Player tracking settings"
		MantellaMCM_PlayerTrackingSettings.Render(self, repository)
		MantellaMCMcurrentPage="Player tracking settings"
	elseif page=="Target tracking settings"
		MantellaMCM_TargetTrackingSettings.Render(self, repository)
		MantellaMCMcurrentPage="Target tracking settings"
	elseif page=="Radiant Dialogue"
		MantellaMCM_RadiantDialogue.Render(self, repository)
		MantellaMCMcurrentPage="Radiant Dialogue"
 	endif		
EndEvent
;This part of the MCM below is a bunch of event listeners, they all use functions to link to the appropriate MCM scripts 
Event OnOptionSelect(int optionID)
	if MantellaMCMcurrentPage =="Main settings"
		MantellaMCM_MainSettings.OptionUpdate(self,optionID, repository)	
	elseif MantellaMCMcurrentPage =="Player tracking settings"
		MantellaMCM_PlayerTrackingSettings.OptionUpdate(self,optionID, repository)	
	elseif MantellaMCMcurrentPage =="Target tracking settings"
		MantellaMCM_TargetTrackingSettings.OptionUpdate(self,optionID, repository)	
	elseif MantellaMCMcurrentPage =="Radiant Dialogue"
		MantellaMCM_RadiantDialogue.OptionUpdate(self,optionID, repository)	
	endif
EndEvent 

Event OnOptionSliderOpen(Int optionId)
    If MantellaMCMcurrentPage =="Main settings"
		MantellaMCM_MainSettings.SliderOptionOpen(self,optionID, repository)
	elseIf MantellaMCMcurrentPage == "Radiant Dialogue"
		MantellaMCM_RadiantDialogue.SliderOptionOpen(self,optionID, repository)
    EndIf
EndEvent

Event OnOptionSliderAccept(Int optionId, Float value)
	If MantellaMCMcurrentPage =="Main settings"
		MantellaMCM_MainSettings.SliderOptionAccept(self,optionID, value, repository)
	elseIf MantellaMCMcurrentPage == "Radiant Dialogue"
		MantellaMCM_RadiantDialogue.SliderOptionAccept(self,optionID, value, repository)
    EndIf
EndEvent

Event OnOptionKeyMapChange(Int a_option, Int a_keyCode, String a_conflictControl, String a_conflictName)
    {Called when a key has been remapped}
    If 	MantellaMCMcurrentPage =="Main settings"
		MantellaMCM_MainSettings.KeyMapChange(self,a_option, a_keyCode, a_conflictControl, a_conflictName, repository)
	EndIf
EndEvent

Event OnOptionHighlight (Int optionID)
	;tooltips for the Mantella Menu
	If 	optionID ==oid_responsetimeslider
		SetInfoText("This slider is used to set the timer (in seconds) to enter a text response when Mantella is ready to receive a text input (microphone disabled only)")
	elseIf optionID ==oid_keymapPromptHotkey	
		SetInfoText("This allows the player to start conversation with a hotkey. It can also be used to force the text prompt to appear during a conversation (microphone disabled only)")
	elseIf optionID ==oid_keymapCustomGameEventHotkey	
		SetInfoText("This allows the player to enter a game event through text using the hotkey. For example, typing 'The house is on fire' will send that information to the AI")
	elseIf optionID ==oid_microphoneEnabledToggle	
		SetInfoText("This turn ON/OFF the microphone input for Mantella (requires Mantella.exe restart)")
	elseIf optionID ==oid_debugNPCSelectMode	
		SetInfoText("This allows the player to speak to any NPC by initiating a conversation then entering the actor RefID then the actor name that the player wishes to speak to")	
	
	;tooltips for the Target Tracking menu
	elseIf optionID ==oid_targetTrackingItemAddedToggle	
		SetInfoText("This tracks if the Mantella Effect's target acquires an item while the Mantella Spell is active.")
	elseIf optionID ==oid_targetTrackingItemRemovedToggle	
		SetInfoText("This tracks if the Mantella Effect's target drops an item while the Mantella Spell is active.")
	elseIf optionID ==oid_targetTrackingOnSpellCastToggle	
		SetInfoText("This tracks if the Mantella Effect's target casts a spell/shout while the Mantella Spell is active.")
	elseIf optionID ==oid_targetTrackingOnHitToggle	
		SetInfoText("This tracks if the Mantella Effect's target is hit by an attack while the Mantella Spell is active.")
	elseIf optionID ==oid_targetTrackingOnCombatStateChangedToggle	
		SetInfoText("This tracks if the Mantella Effect's target changes combat state while the Mantella Spell is active.")
	elseIf optionID ==oid_targetTrackingOnObjectEquippedToggle	
		SetInfoText("This tracks if the Mantella Effect's target equips an item/spell/shout while the Mantella Spell is active.")
	elseIf optionID ==oid_targetTrackingOnObjectUnequippedToggle	
		SetInfoText("This tracks if the Mantella Effect's target unequips an item/spell/shout an item while the Mantella Spell is active.")
	elseIf optionID ==oid_targetTrackingOnSitToggle	
		SetInfoText("This tracks if the Mantella Effect's target sits down on a chair or work area an item while the Mantella Spell is active.")
	elseIf optionID ==oid_targetTrackingOnGetUpToggle	
		SetInfoText("This tracks if the Mantella Effect's target gets up from a chair or work area an item while the Mantella Spell is active.")
	elseIf optionID ==oid_targetTrackingOnGetUpToggle	
		SetInfoText("Turns ON/OFF all tracking options for the target.")
		
	;tooltips for the Player Tracking menu
	elseIf optionID ==oid_playerTrackingOnItemAdded	
		SetInfoText("This tracks if the player acquires an item while the Mantella Spell is active.")
	elseIf optionID ==oid_playerTrackingOnItemRemoved	
		SetInfoText("This tracks if player drops an item while the Mantella Spell is active.")
	elseIf optionID ==oid_playerTrackingOnSpellCast	
		SetInfoText("This tracks if player casts a spell/shout while the Mantella Spell is active.")
	elseIf optionID ==oid_playerTrackingOnHit	
		SetInfoText("This tracks if player is hit by an attack while the Mantella Spell is active.")
	elseIf optionID ==oid_playerTrackingOnLocationChange	
		SetInfoText("This tracks if player changes location while the Mantella Spell is active.")
	elseIf optionID ==oid_playerTrackingOnObjectEquipped	
		SetInfoText("This tracks if player equips an item/spell/shout while the Mantella Spell is active.")
	elseIf optionID ==oid_playerTrackingOnObjectEquipped	
		SetInfoText("This tracks if player unequips an item/spell/shout an item while the Mantella Spell is active.")
	elseIf optionID ==oid_playerTrackingOnPlayerBowShot	
		SetInfoText("This tracks if player shoots an arrow while the Mantella Spell is active")
	elseIf optionID ==oid_playerTrackingOnSit	
		SetInfoText("This tracks if player sits down on a chair or work area an item while the Mantella Spell is active.")
	elseIf optionID ==oid_playerTrackingOnGetUp	
		SetInfoText("This tracks if player gets up from a chair or work area an item while the Mantella Spell is active.")
	elseIf optionID ==oid_playerTrackingAll	
		SetInfoText("Turns ON/OFF all tracking options for the player.")

	;tooltips for the Radiant Dialogue menu
	elseIf optionID == oid_radiantenabled
		SetInfoText("Enable radiant dialogue.")
	elseIf optionID == oid_radiantdistance
		SetInfoText("How far from the player (in meters) radiant dialogues can begin. Default: 20")
	elseIf optionID == oid_radiantfrequency
		SetInfoText("How frequently (in seconds) radiant dialogues should attempt to begin. Default: 30")
	EndIf
endEvent

