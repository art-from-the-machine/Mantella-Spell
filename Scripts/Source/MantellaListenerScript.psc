Scriptname MantellaListenerScript extends ReferenceAlias

Spell property MantellaSpell auto

event OnInit()
    Game.GetPlayer().AddSpell(MantellaSpell)
    Debug.MessageBox("Mantella spell added. Please save and reload to activate the mod.")
endEvent


Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    string itemName = akBaseItem.GetName()
    string itemPickedUpMessage = "The player picked up " + itemName + ".\n"
    
    if itemName != "Iron Arrow" ; Papyrus hallucinates iron arrows
        ;Debug.MessageBox(itemPickedUpMessage)
        MiscUtil.WriteToFile("_mantella_in_game_events.txt", itemPickedUpMessage)
    endIf
EndEvent


Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    string itemName = akBaseItem.GetName()
    string itemDroppedMessage = "The player dropped " + itemName + ".\n"
    
    if itemName != "Iron Arrow" ; Papyrus hallucinates iron arrows
        ;Debug.MessageBox(itemDroppedMessage)
        MiscUtil.WriteToFile("_mantella_in_game_events.txt", itemDroppedMessage)
    endIf
endEvent


Event OnSpellCast(Form akSpell)
    string spellCast = (akSpell as form).getname()
    if spellCast
        if spellCast == "Mantella"
            ; Do not save event if Mantella itself is cast
        else
            ;Debug.Notification("The player casted the spell "+ spellCast)
            MiscUtil.WriteToFile("_mantella_in_game_events.txt", "The player casted the spell " + spellCast + ".\n")
        endIf
    endIf
endEvent


String lastHitSource = ""
String lastAggressor = ""
Int timesHitSameAggressorSource = 0
Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
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
EndEvent


Event OnLocationChange(Location akOldLoc, Location akNewLoc)
    String currLoc = (akNewLoc as form).getname()
    if currLoc == ""
        currLoc = "Skyrim"
    endIf
    ;Debug.MessageBox("Current location is now " + currLoc)
    MiscUtil.WriteToFile("_mantella_in_game_events.txt", "Current location is now " + currLoc+".\n")
endEvent


Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
    string itemEquipped = akBaseObject.getname()
    ;Debug.MessageBox("The player equipped " + itemEquipped)
    MiscUtil.WriteToFile("_mantella_in_game_events.txt", "The player equipped " + itemEquipped + ".\n")
endEvent


Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
    string itemUnequipped = akBaseObject.getname()
    ;Debug.MessageBox("The player unequipped " + itemUnequipped)
    MiscUtil.WriteToFile("_mantella_in_game_events.txt", "The player unequipped " + itemUnequipped + ".\n")
endEvent


Event OnPlayerBowShot(Weapon akWeapon, Ammo akAmmo, float afPower, bool abSunGazing)
    ;Debug.MessageBox("The player fired an arrow.")
    MiscUtil.WriteToFile("_mantella_in_game_events.txt", "The player fired an arrow.\n")
endEvent


Event OnSit(ObjectReference akFurniture)
    ;Debug.MessageBox("The player sat down.")
    MiscUtil.WriteToFile("_mantella_in_game_events.txt", "The player sat down.\n")
endEvent


Event OnGetUp(ObjectReference akFurniture)
    ;Debug.MessageBox("The player stood up.")
    MiscUtil.WriteToFile("_mantella_in_game_events.txt", "The player stood up.\n")
EndEvent


Event OnDying(Actor akKiller)
    MiscUtil.WriteToFile("_mantella_end_conversation.txt", "True",  append=false)
EndEvent