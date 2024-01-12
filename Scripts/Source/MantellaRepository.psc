Scriptname MantellaRepository extends Quest  
Spell property MantellaSpell auto
SPELL Property MantellaEndSpell auto
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


bool property microphoneEnabled auto
float property MantellaEffectResponseTimer auto

int property MantellaListenerTextHotkey auto
int property MantellaEndHotkey auto
int property MantellaCustomGameEventHotkey auto
int property MantellaRadiantHotkey auto

bool property radiantEnabled auto
float property radiantDistance auto
float property radiantFrequency auto


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
;bool property NPCForgive auto ;gia
bool property NPCDialogue auto ;gia

bool property NPCdebugSelectModeEnabled auto

event OnInit()
    microphoneEnabled = true
    MantellaEffectResponseTimer = 180

    MantellaListenerTextHotkey = 35
    BindPromptHotkey(MantellaListenerTextHotkey)
    MantellaEndHotkey = -1
    MantellaCustomGameEventHotkey = -1
    MantellaRadiantHotkey = -1

    radiantEnabled = false
    radiantDistance = 20
    radiantFrequency = 10


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
	;NPCForgive = false ;gia
	NPCDialogue = True ;gia
    
    NPCdebugSelectModeEnabled = false
endEvent

function BindPromptHotkey(int keyCode)
    ;used by the MCM_GeneralSettings when updating the prompt hotkey KeyMapChange
    UnregisterForKey(MantellaListenerTextHotkey)
    MantellaListenerTextHotkey=keyCode
    RegisterForKey(keyCode)
endfunction

function BindEndHotkey(int keyCode)
    ;used by the MCM_GeneralSettings when updating the prompt hotkey KeyMapChange
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

Event OnKeyDown(int KeyCode)
    ;this function was previously in MantellaListener Script back in Mantella 0.9.2
	;this ensures the right key is pressed and only activated while not in menu mode
    if !utility.IsInMenuMode()
        if KeyCode == MantellaListenerTextHotkey
            String radiantDialogue = MiscUtil.ReadFromFile("_mantella_radiant_dialogue.txt") as String

            ;String currentActor = MiscUtil.ReadFromFile("_mantella_current_actor.txt") as String
            String activeActors = MiscUtil.ReadFromFile("_mantella_active_actors.txt") as String
            Actor targetRef = (Game.GetCurrentCrosshairRef() as actor)
            String actorName = targetRef.getdisplayname()
            int index = StringUtil.Find(activeActors, actorName)
            ; if actor not already loaded or player is interrupting radiant dialogue
            if (index == -1) || (radiantDialogue == "True")
                MantellaSpell.cast(Game.GetPlayer(), targetRef)
                Utility.Wait(0.5)
            else
                String playerResponse = "False"
                playerResponse = MiscUtil.ReadFromFile("_mantella_text_input_enabled.txt") as String
                ;Checks if the Mantella is ready for text input and if the MCM has the microphone disabled
                if playerResponse == "True" ;&& !microphoneEnabled
                    ;Debug.Notification("Forcing Conversation Through Hotkey")
                    UIExtensions.InitMenu("UITextEntryMenu")
                    UIExtensions.OpenMenu("UITextEntryMenu")
                    string result = UIExtensions.GetMenuResultString("UITextEntryMenu")
                    if result != ""
                        MiscUtil.WriteToFile("_mantella_text_input_enabled.txt", "False", append=False)
                        MiscUtil.WriteToFile("_mantella_text_input.txt", result, append=false)
                    endIf
                endIf
            endIf
        elseIf KeyCode == MantellaEndHotkey
            MantellaEndSpell.cast(Game.GetPlayer())
        elseIf KeyCode == MantellaCustomGameEventHotkey
            UIExtensions.InitMenu("UITextEntryMenu")
            UIExtensions.OpenMenu("UITextEntryMenu")
            string gameEventEntry = UIExtensions.GetMenuResultString("UITextEntryMenu")
            gameEventEntry = gameEventEntry+"\n"
            MiscUtil.WriteToFile("_mantella_in_game_events.txt", gameEventEntry)
        elseIf KeyCode == MantellaRadiantHotkey
            radiantEnabled =! radiantEnabled
            if radiantEnabled == True
                Debug.Notification("Radiant Dialogue Enabled")
            else
                Debug.Notification("Radiant Dialogue Disabled")
            endIf
        endIf
    endIf
endEvent