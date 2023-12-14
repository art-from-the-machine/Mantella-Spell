Scriptname MantellaListenerScript extends ReferenceAlias

Spell property MantellaSpell auto
Spell property MantellaPower auto;gia
MantellaRepository property repository auto

event OnInit()
    Game.GetPlayer().AddSpell(MantellaSpell)
    Game.GetPlayer().AddSpell(MantellaPower);gia
    Debug.Notification("Mantella spell added.")
    Debug.Notification("IMPORTANT: Please save and reload to activate the mod.")
endEvent

; ##################
;This has been removed after Mantella 0.9.2 since it's not necessary anymore
;Event OnPlayerLoadGame()
	;this will load the selected hotkey for the conversation press.
;	conversationHotkey = MiscUtil.ReadFromFile("_mantella_conversation_hotkey.txt") as int

;	RegisterForKey(conversationHotkey)
;EndEvent
; ##################

;onkeydown event moved to the MantellaRepository after Mantella 0.9.2

;All the event listeners  below have 'if' clauses added after Mantella 0.9.2 (except ondying)
Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    if repository.playerTrackingOnItemAdded
        
        string itemName = akBaseItem.GetName()
        string itemPickedUpMessage = "The player picked up " + itemName + ".\n"
        if itemName != "Iron Arrow" ; Papyrus hallucinates iron arrows
            ;Debug.MessageBox(itemPickedUpMessage)
            MiscUtil.WriteToFile("_mantella_in_game_events.txt", itemPickedUpMessage)
        endIf
    endif
EndEvent


Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    if Repository.playerTrackingOnItemRemoved
        string itemName = akBaseItem.GetName()
        string itemDroppedMessage = "The player dropped " + itemName + ".\n"
        
        if itemName != "Iron Arrow" ; Papyrus hallucinates iron arrows
            ;Debug.MessageBox(itemDroppedMessage)
            MiscUtil.WriteToFile("_mantella_in_game_events.txt", itemDroppedMessage)
        endIf
    endif
endEvent


Event OnSpellCast(Form akSpell)
    if repository.playerTrackingOnSpellCast
    string spellCast = (akSpell as form).getname()
        if spellCast
            if spellCast == "Mantella"
                ; Do not save event if Mantella itself is cast
            else
                ;Debug.Notification("The player casted the spell "+ spellCast)
                MiscUtil.WriteToFile("_mantella_in_game_events.txt", "The player casted the spell " + spellCast + ".\n")
            endIf
        endIf
    endif
endEvent


String lastHitSource = ""
String lastAggressor = ""
Int timesHitSameAggressorSource = 0
Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    if repository.playerTrackingOnHit
        string aggressor = akAggressor.getdisplayname()
        string hitSource = akSource.getname()

        ; avoid writing events too often (continuous spells record very frequently)
        ; if the actor and weapon hasn't changed, only record the event every 5 hits
        if ((hitSource != lastHitSource) && (aggressor != lastAggressor)) || (timesHitSameAggressorSource > 5)
            lastHitSource = hitSource
            lastAggressor = aggressor
            timesHitSameAggressorSource = 0

            if (hitSource == "None") || (hitSource == "")
                ;Debug.MessageBox(aggressor + " punched the player.")
                MiscUtil.WriteToFile("_mantella_in_game_events.txt", aggressor + " punched the player.\n")
            else
                ;Debug.MessageBox(aggressor + " hit the player with " + hitSource+".\n")
                MiscUtil.WriteToFile("_mantella_in_game_events.txt", aggressor + " hit the player with " + hitSource+".\n")
            endIf
        else
            timesHitSameAggressorSource += 1
        endIf
    endif
EndEvent


Event OnLocationChange(Location akOldLoc, Location akNewLoc)
    if repository.playerTrackingOnLocationChange
        String currLoc = (akNewLoc as form).getname()
        if currLoc == ""
            currLoc = "Skyrim"
        endIf
        ;Debug.MessageBox("Current location is now " + currLoc)
        MiscUtil.WriteToFile("_mantella_in_game_events.txt", "Current location is now " + currLoc+".\n")
    endif
endEvent


Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
    if repository.playerTrackingOnObjectEquipped
        string itemEquipped = akBaseObject.getname()
        ;Debug.MessageBox("The player equipped " + itemEquipped)
        MiscUtil.WriteToFile("_mantella_in_game_events.txt", "The player equipped " + itemEquipped + ".\n")
    endif
endEvent


Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
    if repository.playerTrackingOnObjectUnequipped
        string itemUnequipped = akBaseObject.getname()
        ;Debug.MessageBox("The player unequipped " + itemUnequipped)
        MiscUtil.WriteToFile("_mantella_in_game_events.txt", "The player unequipped " + itemUnequipped + ".\n")
    endif
endEvent


Event OnPlayerBowShot(Weapon akWeapon, Ammo akAmmo, float afPower, bool abSunGazing)
    if repository.playerTrackingOnPlayerBowShot
        ;Debug.MessageBox("The player fired an arrow.")
        MiscUtil.WriteToFile("_mantella_in_game_events.txt", "The player fired an arrow.\n")
    endif
endEvent


Event OnSit(ObjectReference akFurniture)
    if repository.playerTrackingOnSit
        ;Debug.MessageBox("The player sat down.")
        MiscUtil.WriteToFile("_mantella_in_game_events.txt", "The player sat down.\n")
    endif
endEvent


Event OnGetUp(ObjectReference akFurniture)
    if repository.playerTrackingOnGetUp
        ;Debug.MessageBox("The player stood up.")
        MiscUtil.WriteToFile("_mantella_in_game_events.txt", "The player stood up.\n")
    endif
EndEvent


Event OnDying(Actor akKiller)
    MiscUtil.WriteToFile("_mantella_end_conversation.txt", "True",  append=false)
EndEvent

