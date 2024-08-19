Scriptname MantellaRepository extends Quest Conditional
Spell property MantellaSpell auto
Spell property MantellaRemoveNpcSpell auto
Spell Property MantellaEndSpell auto
string property currentSKversion auto ;ex : returns "1.6.640.0" 
;Faction Property giafac_Sitters  Auto ;gia
;Faction Property giafac_Sleepers  Auto ;gia
;Faction Property giafac_talktome  Auto ;gia
Faction Property giafac_AllowFollower  Auto ;gia
Faction Property giafac_AllowAnger  Auto ;gia
;Faction Property giafac_AllowForgive  Auto ;gia
Faction Property giafac_AllowDialogue  Auto ;gia
Faction Property giafac_Following  Auto ;gia
Faction Property giafac_Mantella  Auto ;gia
quest property gia_FollowerQst auto ;gia
Sound Property ScreenshotSound Auto



;;;;;;;;;;;;;;;;;;;
;Vision variables ;
;;;;;;;;;;;;;;;;;;;
bool property allowVision auto
bool property allowVisionHints auto
bool property hasPendingVisionCheck auto
bool property isUsingSteamScreenshot auto
bool property allowVisionDebugMode auto
string property visionResolution auto
int property visionResolutionIndex auto
int property visionResize auto
int property MantellaVisionHotkey auto
int property MantellaVisionHintsHotkey auto
bool property allowHideInterfaceDuringScreenshot auto
String property ActorsInCellArray auto
String property VisionDistanceArray auto
int property steamScreenshotDelay auto
;;;;;;;;;;;;;;;;;;;

bool property microphoneEnabled auto
float property MantellaEffectResponseTimer auto

int property MantellaStartHotkey auto
int property MantellaListenerTextHotkey auto
int property MantellaEndHotkey auto
int property MantellaCustomGameEventHotkey auto
int property MantellaRadiantHotkey auto

bool property showDialogueItems auto Conditional

bool property radiantEnabled auto
float property radiantDistance auto
float property radiantFrequency auto


bool property playerTrackingUsePCName auto
bool property playerTrackingOnItemAdded auto
bool property playerTrackingOnItemRemoved auto
bool property playerTrackingOnSpellCast auto
bool property playerTrackingOnHit auto
bool property playerTrackingOnLocationChange auto
bool property playerTrackingOnObjectEquipped auto
bool property playerTrackingOnObjectUnequipped auto
bool property playerTrackingOnPlayerBowShot auto
bool property playerTrackingOnSit auto
bool property playerTrackingOnGetUp auto


bool property targetTrackingItemAdded auto 
bool property targetTrackingItemRemoved auto
bool property targetTrackingOnSpellCast auto
bool property targetTrackingOnHit auto
bool property targetTrackingOnCombatStateChanged auto
bool property targetTrackingOnObjectEquipped auto
bool property targetTrackingOnObjectUnequipped auto
bool property targetTrackingOnSit auto
bool property targetTrackingOnGetUp auto


bool property AllowForNPCtoFollow auto ;gia
;bool property followingNPCsit auto ;gia
;bool property followingNPCsleep auto ;gia
;bool property NPCstopandTalk auto ;gia
bool property NPCAnger auto ;gia
bool property NPCPackage auto Conditional
;bool property NPCForgive auto ;gia
bool property NPCDialogue auto ;gia

bool property NPCdebugSelectModeEnabled auto

int property HttpPort auto

event OnInit()
    allowVision = false 
    allowVisionHints = false
    isUsingSteamScreenshot = false
    hasPendingVisionCheck = false
    visionResolution = "auto"
    visionResolutionIndex=0
    visionResize=1024
    allowVisionDebugMode = false
    steamScreenshotDelay = 120

    microphoneEnabled = true
    MantellaEffectResponseTimer = 180

    MantellaStartHotkey = -1
    MantellaListenerTextHotkey = 35
    BindPromptHotkey(MantellaListenerTextHotkey)
    MantellaEndHotkey = -1
    MantellaCustomGameEventHotkey = -1
    MantellaRadiantHotkey = -1
    MantellaVisionHotkey = -1
    MantellaVisionHintsHotkey = -1

    showDialogueItems = true

    radiantEnabled = false
    radiantDistance = 20
    radiantFrequency = 10


    playerTrackingUsePCName = true
    playerTrackingOnItemAdded = true
    playerTrackingOnItemRemoved = true
    playerTrackingOnSpellCast = true
    playerTrackingOnHit = true
    playerTrackingOnLocationChange = true
    playerTrackingOnObjectEquipped = true
    playerTrackingOnObjectUnequipped = true
    playerTrackingOnPlayerBowShot = true
    playerTrackingOnSit = true
    playerTrackingOnGetUp = true
    

    targetTrackingItemAdded = true
    targetTrackingItemRemoved = true
    targetTrackingOnSpellCast = true
    targetTrackingOnHit = true
    targetTrackingOnCombatStateChanged = true
    targetTrackingOnObjectEquipped = true
    targetTrackingOnObjectUnequipped = true
    targetTrackingOnSit = true
    targetTrackingOnGetUp = true
	

	;followingNPCsit = false ;gia
	;followingNPCsleep = false ;gia
	;NPCstopandTalk = false ;gia
	AllowForNPCtoFollow = false ;gia
	NPCAnger = false ;gia
    NPCPackage = true
	;NPCForgive = false ;gia
	NPCDialogue = True ;gia
    
    NPCdebugSelectModeEnabled = false

    HttpPort = 4999
endEvent

function BindStartAddHotkey(int keyCode)
    ;used by the MCM_GeneralSettings when updating the start hotkey KeyMapChange
    UnregisterForKey(MantellaStartHotkey)
    MantellaStartHotkey=keyCode
    RegisterForKey(keyCode)
endfunction

function BindPromptHotkey(int keyCode)
    ;used by the MCM_GeneralSettings when updating the prompt hotkey KeyMapChange
    UnregisterForKey(MantellaListenerTextHotkey)
    MantellaListenerTextHotkey=keyCode
    RegisterForKey(keyCode)
endfunction

function BindEndHotkey(int keyCode)
    ;used by the MCM_GeneralSettings when updating the end hotkey KeyMapChange
    UnregisterForKey(MantellaEndHotkey)
    MantellaEndHotkey=keyCode
    RegisterForKey(keyCode)
endfunction

function BindCustomGameEventHotkey(int keyCode)
    ;used by the MCM_GeneralSettings when updating the custom game event hotkey KeyMapChange
    UnregisterForKey(MantellaCustomGameEventHotkey)
    MantellaCustomGameEventHotkey=keyCode
    RegisterForKey(keyCode)
endfunction

function BindRadiantHotkey(int keyCode)
    ;used by the MCM_GeneralSettings when updating the prompt hotkey KeyMapChange
    UnregisterForKey(MantellaRadiantHotkey)
    MantellaRadiantHotkey=keyCode
    RegisterForKey(keyCode)
endfunction

function BindVisionHotkey(int keyCode)
    ;used by the MCM_GeneralSettings when updating the start hotkey KeyMapChange
    UnregisterForKey(MantellaVisionHotkey)
    MantellaVisionHotkey=keyCode
    RegisterForKey(keyCode)
endfunction

function BindVisionHintsHotkey(int keyCode)
    ;used by the MCM_GeneralSettings when updating the start hotkey KeyMapChange
    UnregisterForKey(MantellaVisionHintsHotkey)
    MantellaVisionHintsHotkey=keyCode
    RegisterForKey(keyCode)
endfunction

Event OnKeyDown(int KeyCode)
    ;this function was previously in MantellaListener Script back in Mantella 0.9.2
	;this ensures the right key is pressed and only activated while not in menu mode
    if !utility.IsInMenuMode()
        if KeyCode == MantellaVisionHotkey
            MantellaVisionScript.GenerateMantellaVision(self)
            ScreenshotSound.play(game.getplayer())
        endif
        if KeyCode == MantellaVisionHintsHotkey
            MantellaVisionScript.ScanCellForActors(self, true, true)
            ScreenshotSound.play(game.getplayer())
        endif
        if KeyCode == MantellaStartHotkey
            Actor targetRef = (Game.GetCurrentCrosshairRef() as actor)            
            if (targetRef) ;If we have a target under the crosshair, cast sepll on it
                MantellaSpell.cast(Game.GetPlayer(), targetRef)
                Utility.Wait(0.5)
            endIf        
        elseIf KeyCode == MantellaListenerTextHotkey
            If(!microphoneEnabled) ;Otherwise, try to open player text input if microphone is off
                MantellaConversation conversation = Quest.GetQuest("MantellaConversation") as MantellaConversation
                if(conversation.IsRunning())
                    conversation.GetPlayerTextInput()
                endIf
            endif
        elseIf KeyCode == MantellaEndHotkey
            Actor targetRef = (Game.GetCurrentCrosshairRef() as actor)            
            if (targetRef) ;If we have a target under the crosshair, cast sepll on it
                MantellaRemoveNpcSpell.cast(Game.GetPlayer(), targetRef)
            else
                MantellaEndSpell.cast(Game.GetPlayer())
            endIf
        elseIf KeyCode == MantellaCustomGameEventHotkey
            MantellaConversation conversation = Quest.GetQuest("MantellaConversation") as MantellaConversation
            if(conversation.IsRunning())
                UIExtensions.InitMenu("UITextEntryMenu")
                UIExtensions.OpenMenu("UITextEntryMenu")
                string gameEventEntry = UIExtensions.GetMenuResultString("UITextEntryMenu")
                if (gameEventEntry && gameEventEntry != "")
                    gameEventEntry = gameEventEntry+"\n"
                    conversation.AddIngameEvent(gameEventEntry)
                endIf
            endIf
        elseIf KeyCode == MantellaRadiantHotkey
            radiantEnabled =! radiantEnabled
            if radiantEnabled == True
                Debug.Notification("Radiant Dialogue enabled.")
            else
                Debug.Notification("Radiant Dialogue disabled.")
            endIf
        endIf
    endIf
endEvent