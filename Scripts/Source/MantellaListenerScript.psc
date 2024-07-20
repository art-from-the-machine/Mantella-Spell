Scriptname MantellaListenerScript extends ReferenceAlias

Spell property MantellaSpell auto
Spell property MantellaPower auto;gia
Spell Property MantellaEndSpell auto
Spell Property MantellaEndPower auto
Spell Property MantellaRemoveNpcSpell auto
Spell Property MantellaRemoveNpcPower auto
MantellaRepository property repository auto
Quest Property MantellaActorPicker auto  
ReferenceAlias Property PotentialActor1 auto  
ReferenceAlias Property PotentialActor2 auto  
MantellaConversation Property conversation auto
MantellaMCM Property MantellaMCMQuest auto

event OnInit()
    Game.GetPlayer().AddSpell(MantellaSpell)
    Game.GetPlayer().AddSpell(MantellaPower);gia
    Game.GetPlayer().AddSpell(MantellaEndSpell)
    Game.GetPlayer().AddSpell(MantellaEndPower)
    Game.GetPlayer().AddSpell(MantellaRemoveNpcSpell)
    Game.GetPlayer().AddSpell(MantellaRemoveNpcPower)
    Game.GetPlayer().AddToFaction(repository.giafac_AllowDialogue);gia
    Debug.Notification("Please save and reload to activate Mantella.")
endEvent

Function AddIngameEventToConversation(string eventText)
    If (conversation.IsRunning())
        conversation.AddIngameEvent(eventText)
    EndIf
EndFunction

Float meterUnits = 71.0210
Float Function ConvertMeterToGameUnits(Float meter)
    Return Meter * meterUnits
EndFunction

Float Function ConvertGameUnitsToMeter(Float gameUnits)
    Return gameUnits / meterUnits
EndFunction

string Function getPlayerName(bool isStartOfSentence = True)
    if (repository.playerTrackingUsePCName)
        return Game.GetPlayer().GetDisplayName()
    Elseif (isStartOfSentence)
        return "The player"
    Else
        return "the player"
    endif
EndFunction

Event OnPlayerLoadGame()
    If(conversation.IsRunning())
        conversation.EndConversation()
    endif
    If (MantellaMCMQuest.IsRunning() && MantellaMCMQuest.IsNotProperlyInitialised())
        Debug.MessageBox("Detecting old version of Mantella in this save. MCM settings will be reset once.")
        MantellaMCMQuest.Stop()
        MantellaMCMQuest.Start()
        MantellaMCMQuest.OnConfigInit()
        repository.assignDefaultSettings(0,true)
    EndIf
    RegisterForSingleUpdate(repository.radiantFrequency)
EndEvent

event OnUpdate()
    if repository.radiantEnabled
        ; if no Mantella conversation active
        if !conversation.IsRunning()
            ;MantellaActorList taken from this tutorial:
            ;http://skyrimmw.weebly.com/skyrim-modding/detecting-nearby-actors-skyrim-modding-tutorial
            MantellaActorPicker.start()

            ; if both actors found
            if (PotentialActor1.GetReference() as Actor) && (PotentialActor2.GetReference() as Actor)
                Actor Actor1 = PotentialActor1.GetReference() as Actor
                Actor Actor2 = PotentialActor2.GetReference() as Actor

                float distanceToClosestActor = game.getplayer().GetDistance(Actor1)
                float maxDistance = ConvertMeterToGameUnits(repository.radiantDistance)
                if distanceToClosestActor <= maxDistance
                    String Actor1Name = Actor1.getdisplayname()
                    String Actor2Name = Actor2.getdisplayname()
                    float distanceBetweenActors = Actor1.GetDistance(Actor2)

                    ;TODO: make distanceBetweenActors customisable
                    if (distanceBetweenActors <= 1000)
                        ;have spell casted on Actor 1 by Actor 2
                        MantellaSpell.Cast(Actor2 as ObjectReference, Actor1 as ObjectReference)
                    elseif(repository.showRadiantDialogueMessages)
                        Debug.Notification("Radiant dialogue attempted. No NPCs available")
                    endIf
                elseif(repository.showRadiantDialogueMessages)
                    Debug.Notification("Radiant dialogue attempted. NPCs too far away at " + ConvertGameUnitsToMeter(distanceToClosestActor) + " meters")
                    Debug.Notification("Max distance set to " + repository.radiantDistance + "m in Mantella MCM")
                endIf
            elseif(repository.showRadiantDialogueMessages)
                Debug.Notification("Radiant dialogue attempted. No NPCs available")
            endIf

            MantellaActorPicker.stop()
        endIf
    endIf
    RegisterForSingleUpdate(repository.radiantFrequency)
endEvent


;All the event listeners  below have 'if' clauses added after Mantella 0.9.2 (except ondying)
Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    if repository.playerTrackingOnItemAdded
        
        string itemName = akBaseItem.GetName()
        string itemPickedUpMessage = getPlayerName() + " picked up " + itemName 

        string sourceName = akSourceContainer.getbaseobject().getname()
        if sourceName != ""
            itemPickedUpMessage = getPlayerName() + " picked up " + itemName + " from " + sourceName 
        endIf
        
        if itemName != "Iron Arrow" ; Papyrus hallucinates iron arrows
            ;Debug.MessageBox(itemPickedUpMessage)
            AddIngameEventToConversation(itemPickedUpMessage)
        endIf
    endif
EndEvent


Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    if Repository.playerTrackingOnItemRemoved
        string itemName = akBaseItem.GetName()
        string itemDroppedMessage = getPlayerName() + " dropped " + itemName 

        string destName = akDestContainer.getbaseobject().getname()
        if destName != ""
            itemDroppedMessage = getPlayerName() + " placed " + itemName + " in/on " + destName 
        endIf
        
        if itemName != "Iron Arrow" ; Papyrus hallucinates iron arrows
            ;Debug.MessageBox(itemDroppedMessage)
            AddIngameEventToConversation(itemDroppedMessage)
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
                AddIngameEventToConversation(getPlayerName() + " casted the spell " + spellCast )
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
            
            if (aggressor == "None") || (aggressor == "")
                AddIngameEventToConversation(getPlayerName() + " took damage.")
            elseif (hitSource == "None") || (hitSource == "")
                ;Debug.MessageBox(aggressor + " punched the player.")
                AddIngameEventToConversation(aggressor + " punched " + getPlayerName(False) + " .")
            else
                ;Debug.MessageBox(aggressor + " hit the player with " + hitSource)
                AddIngameEventToConversation(aggressor + " hit " + getPlayerName(False) + " with " + hitSource)
            endIf
        else
            timesHitSameAggressorSource += 1
        endIf
    endif
EndEvent


Event OnLocationChange(Location akOldLoc, Location akNewLoc)
    ; check if radiant dialogue is playing, and end conversation if the player leaves the area
    If (conversation.IsRunning() && !conversation.IsPlayerInConversation())
        conversation.EndConversation()
    EndIf

    if repository.playerTrackingOnLocationChange
        String currLoc = (akNewLoc as form).getname()
        if currLoc == ""
            currLoc = "Skyrim"
        endIf
        ;Debug.MessageBox("Current location is now " + currLoc)
        ;ToDo: Set the location as a context and not as an ingame event
        AddIngameEventToConversation("Current location is now " + currLoc)
    endif
endEvent


Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
    if repository.playerTrackingOnObjectEquipped
        string itemEquipped = akBaseObject.getname()
        ;Debug.MessageBox("The player equipped " + itemEquipped)
        AddIngameEventToConversation(getPlayerName() + " equipped " + itemEquipped )
    endif
endEvent


Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
    if repository.playerTrackingOnObjectUnequipped
        string itemUnequipped = akBaseObject.getname()
        ;Debug.MessageBox("The player unequipped " + itemUnequipped)
        AddIngameEventToConversation(getPlayerName() + " unequipped " + itemUnequipped )
    endif
endEvent


Event OnPlayerBowShot(Weapon akWeapon, Ammo akAmmo, float afPower, bool abSunGazing)
    if repository.playerTrackingOnPlayerBowShot
        ;Debug.MessageBox("The player fired an arrow.")
        AddIngameEventToConversation(getPlayerName() + " fired an arrow.")
    endif
endEvent


Event OnSit(ObjectReference akFurniture)
    if repository.playerTrackingOnSit
        ; Debug.MessageBox("playerTrackingOnSit is true")
        String furnitureName = akFurniture.getbaseobject().getname()
        AddIngameEventToConversation(getPlayerName() + " rested on / used a(n) "+furnitureName)
    endif
endEvent


Event OnGetUp(ObjectReference akFurniture)
    if repository.playerTrackingOnGetUp
        ;Debug.MessageBox("The player stood up.")
        String furnitureName = akFurniture.getbaseobject().getname()
        AddIngameEventToConversation(getPlayerName() + " stood up from a(n) "+furnitureName)
    endif
EndEvent


Event OnDying(Actor akKiller)
    If (conversation.IsRunning())
        conversation.EndConversation()
    EndIf
EndEvent

