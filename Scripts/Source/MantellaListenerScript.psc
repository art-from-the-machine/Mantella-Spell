Scriptname MantellaListenerScript extends ReferenceAlias

Spell property MantellaSpell auto
Spell property MantellaPower auto;gia
Spell Property MantellaEndSpell auto
Spell Property MantellaEndPower auto
Spell Property MantellaRemoveNpcSpell auto
Spell Property MantellaRemoveNpcPower auto
MantellaRepository property repository auto
MantellaConversation Property conversation auto
MantellaMCM Property MantellaMCMQuest auto
Actor Property PlayerRef Auto

Quest Property MantellaActorPicker auto  
ReferenceAlias Property PotentialActor1 auto  
ReferenceAlias Property PotentialActor2 auto  
ReferenceAlias Property PotentialActor3 auto  
ReferenceAlias Property PotentialActor4 auto  
ReferenceAlias Property PotentialActor5 auto  

Quest Property MantellaNearbyActors Auto
ReferenceAlias Property NearbyActor1 Auto
ReferenceAlias Property NearbyActor2 Auto
ReferenceAlias Property NearbyActor3 Auto
ReferenceAlias Property NearbyActor4 Auto
ReferenceAlias Property NearbyActor5 Auto



event OnInit()
    PlayerRef.AddSpell(MantellaSpell)
    PlayerRef.AddSpell(MantellaPower);gia
    PlayerRef.AddSpell(MantellaEndSpell)
    PlayerRef.AddSpell(MantellaEndPower)
    PlayerRef.AddSpell(MantellaRemoveNpcSpell)
    PlayerRef.AddSpell(MantellaRemoveNpcPower)
    PlayerRef.AddToFaction(repository.giafac_AllowDialogue);gia
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

Int Function ConvertGameUnitsToMeter(Float gameUnits)
    Return Math.Floor(gameUnits / meterUnits)
EndFunction

string Function getPlayerName(bool isStartOfSentence = True)
    if (repository.playerTrackingUsePCName)
        return PlayerRef.GetDisplayName()
    Elseif (isStartOfSentence)
        return "The player"
    Else
        return "the player"
    endif
EndFunction

bool Function TryAddActorToParticipantsList(ReferenceAlias potentialActor, Actor anchorActor, int index, Actor[] actorArray, float maxDistance)
    if (potentialActor.GetReference() as Actor)
        Actor newActor = potentialActor.GetReference() as Actor
        float distance = anchorActor.GetDistance(newActor)
        if distance <= maxDistance
            actorArray[index] = newActor
            return true
        endIf
    endIf
    return false
endFunction

Event OnPlayerLoadGame()
    If(conversation.IsRunning())
        conversation.EndConversation()
    endif
    ; conversation.RegisterForConversationEvents()
    RegisterForSingleUpdate(repository.radiantFrequency)
EndEvent

function StartGroupConversation()
    ; TODO: Remove redundancy with OnUpdate code
    ; If no Mantella conversation active
    if !conversation.IsRunning()
        ; MantellaActorList taken from this tutorial:
        ; http://skyrimmw.weebly.com/skyrim-modding/detecting-nearby-actors-skyrim-modding-tutorial
        MantellaActorPicker.start()

        ; If at least one actor found
        if (PotentialActor1.GetReference() as Actor)
            Actor Actor1 = PotentialActor1.GetReference() as Actor

            ; First check if the player is close enough to the actors
            float distanceFromPlayerToClosestActor = PlayerRef.GetDistance(Actor1)
            float maxDistance = ConvertMeterToGameUnits(repository.radiantDistance)
            if distanceFromPlayerToClosestActor <= maxDistance
                Actor[] actors = new Actor[6]
                actors[0] = PlayerRef
                actors[1] = Actor1

                ; Search for other potential actors to add
                if TryAddActorToParticipantsList(PotentialActor2, PlayerRef, 2, actors, maxDistance)
                    if TryAddActorToParticipantsList(PotentialActor3, PlayerRef, 3, actors, maxDistance)
                        if TryAddActorToParticipantsList(PotentialActor4, PlayerRef, 4, actors, maxDistance)
                            if TryAddActorToParticipantsList(PotentialActor5, PlayerRef, 5, actors, maxDistance)
                                ; All actors added successfully
                            endIf
                        endIf
                    endIf
                endIf

                Debug.Notification("Starting conversation...")
                conversation.Start()
                conversation.StartConversation(actors)
            elseif(repository.showRadiantDialogueMessages)
                Debug.Notification("Group ocnversation attempted. NPCs too far away at " + ConvertGameUnitsToMeter(distanceFromPlayerToClosestActor) + " meters")
                Debug.Notification("Max distance set to " + repository.radiantDistance as int + "m in Mantella MCM")
            endIf
        elseif(repository.showRadiantDialogueMessages)
            Debug.Notification("Group conversation attempted. No NPCs available")
        endIf

        MantellaActorPicker.stop()
    endIf
endFunction

Actor[] Function ScanNearbyActors()
    MantellaNearbyActors.start()

    Actor[] nearbyActors = new Actor[5]
    
    if (NearbyActor1.GetReference() as Actor)
        nearbyActors[0] = NearbyActor1.GetReference() as Actor
        if (NearbyActor2.GetReference() as Actor)
            nearbyActors[1] = NearbyActor2.GetReference() as Actor
            if (NearbyActor3.GetReference() as Actor)
                nearbyActors[2] = NearbyActor3.GetReference() as Actor
                if (NearbyActor4.GetReference() as Actor)
                    nearbyActors[3] = NearbyActor4.GetReference() as Actor
                    if (NearbyActor5.GetReference() as Actor)
                        nearbyActors[4] = NearbyActor5.GetReference() as Actor
                    endIf
                endIf
            endIf
        endIf
    endIf
    
    MantellaNearbyActors.stop()
    
    return nearbyActors
EndFunction

event OnUpdate()
    ; If no Mantella conversation active
    if !conversation.IsRunning()
        if repository.radiantEnabled || repository.approachEnabled
            ; MantellaActorList taken from this tutorial:
            ; http://skyrimmw.weebly.com/skyrim-modding/detecting-nearby-actors-skyrim-modding-tutorial
            MantellaActorPicker.start()

            int randomPct = Utility.RandomInt(1, 100)

            if repository.radiantEnabled && (!repository.approachEnabled || randomPct <= repository.triggerRatio)
                ; If at least two actors found
                if (PotentialActor1.GetReference() as Actor) && (PotentialActor2.GetReference() as Actor)
                    Actor Actor1 = PotentialActor1.GetReference() as Actor
                    Actor Actor2 = PotentialActor2.GetReference() as Actor

                    ; First check if the player is close enough to the actors
                    float distanceFromPlayerToClosestActor = PlayerRef.GetDistance(Actor1)
                    float maxDistance = ConvertMeterToGameUnits(repository.radiantDistance)
                    if distanceFromPlayerToClosestActor <= maxDistance
                        ; Then check the distance between actors
                        float distanceBetweenActors = Actor1.GetDistance(Actor2)
                        ; TODO: make distanceBetweenActors customisable
                        if (distanceBetweenActors <= 1000)
                            Actor[] actors = new Actor[5]
                            actors[0] = Actor1
                            actors[1] = Actor2

                            ; Search for other potential actors to add
                            if TryAddActorToParticipantsList(PotentialActor3, Actor1, 2, actors, 1000)
                                if TryAddActorToParticipantsList(PotentialActor4, Actor1, 3, actors, 1000)
                                    if TryAddActorToParticipantsList(PotentialActor5, Actor1, 4, actors, 1000)
                                        ; All actors added successfully
                                    endIf
                                endIf
                            endIf

                            Debug.Notification("Starting conversation...")
                            conversation.Start()
                            conversation.StartConversation(actors)

                        elseif(repository.showRadiantDialogueMessages)
                            Debug.Notification("Radiant dialogue attempted. No NPCs available")
                        endIf
                    elseif(repository.showRadiantDialogueMessages)
                        Debug.Notification("Radiant dialogue attempted. NPCs too far away at " + ConvertGameUnitsToMeter(distanceFromPlayerToClosestActor) + " meters")
                        Debug.Notification("Max distance set to " + repository.radiantDistance as int + "m in Mantella MCM")
                    endIf
                elseif(repository.showRadiantDialogueMessages)
                    Debug.Notification("Radiant dialogue attempted. No NPCs available")
                endIf
            elseIf repository.approachEnabled
                ; If at least one actor found
                if (PotentialActor1.GetReference() as Actor)
                    Actor Actor1 = PotentialActor1.GetReference() as Actor

                    ; Check if the player is close enough to the actor
                    float distanceFromPlayerToClosestActor = PlayerRef.GetDistance(Actor1)
                    float maxDistance = ConvertMeterToGameUnits(repository.radiantDistance)
                    if distanceFromPlayerToClosestActor <= maxDistance
                        Actor[] actors = new Actor[2]
                        actors[0] = PlayerRef
                        actors[1] = Actor1

                        conversation.Start()
                        Debug.Notification(Actor1.GetDisplayName() + " approaches...")
                        conversation.AddIngameEvent(Actor1.GetDisplayName() + " approaches " + getPlayerName(False) + " with something on their mind.")
                        conversation.StartConversation(actors)
                        conversation.TriggerApproachMoveAction(Actor1)

                    elseif (repository.showRadiantDialogueMessages)
                        Debug.Notification("NPC approach attempted. NPC too far away at " + ConvertGameUnitsToMeter(distanceFromPlayerToClosestActor) + " meters")
                        Debug.Notification("Max distance set to " + repository.radiantDistance as int + "m in Mantella MCM")
                    endIf
                elseif (repository.showRadiantDialogueMessages)
                    Debug.Notification("NPC approach attempted. No NPCs available")
                endIf
            endIf

            MantellaActorPicker.stop()
        endIf
    endIf
    RegisterForSingleUpdate(repository.radiantFrequency)
endEvent


;All the event listeners below have 'if' clauses added after Mantella 0.9.2 (except ondying)
Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    if repository.playerTrackingOnItemAdded
        string itemName = akBaseItem.GetName()
        string itemCount = ""
        if itemName == "gold" ; only count the number of items if it is gold
            itemCount = aiItemCount+" "
        endIf
        string sourceName = ""
        if akSourceContainer != None ; if the source container is a container, not an actor
            sourceName = " from " + akSourceContainer.getdisplayname()
        endif
        string itemPickedUpMessage = getPlayerName() + " picked up / took " + itemCount + itemName + sourceName                 
        if itemName != "Iron Arrow" ; Papyrus hallucinates iron arrows
            ;Debug.MessageBox(itemPickedUpMessage)
            AddIngameEventToConversation(itemPickedUpMessage)
        endIf
    endif
EndEvent


Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    if Repository.playerTrackingOnItemRemoved
        string itemName = akBaseItem.GetName()
        string itemCount = ""
        if itemName == "gold" ; only count the number of items if it is gold
            itemCount = aiItemCount + " "
        endIf
        string destName = ""
        if akDestContainer != None
            destName = " in/on/to " + akDestContainer.getdisplayname()
        endif
        string itemDroppedMessage = getPlayerName() + " dropped/gave " + itemCount + itemName + destName      
        if itemName != "Iron Arrow" ; Papyrus hallucinates iron arrows
            ;Debug.MessageBox(itemDroppedMessage)
            AddIngameEventToConversation(itemDroppedMessage)
        endIf
    endif
endEvent


Event OnSpellCast(Form akSpell)
    string spellCast = (akSpell as form).getname()
    if (spellCast == "Mantella")
        ; Wait a second to see if the spell hits a target NPC
        Utility.Wait(1.0)
        ; If the spell did not hit a target NPC, start a conversation with all available NPCs in the area
        if !conversation.IsRunning()
            StartGroupConversation()
        endIf
    endIf

    if (repository.playerTrackingOnSpellCast)
        if spellCast 
            if (spellCast != "Mantella") && (spellCast != "Mantella Remove NPC") && (spellCast != "Mantella End Conversation")
                ;Debug.Notification("The player cast the spell "+ spellCast)
                AddIngameEventToConversation(getPlayerName() + " cast the spell / consumed " + spellCast )
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
        if ((hitSource != lastHitSource) && (aggressor != lastAggressor)) || (timesHitSameAggressorSource > 5) && (hitSource != "Mantella") && (hitSource != "Mantella Remove NPC") && (hitSource != "Mantella End Conversation")
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
    elseIf repository.playerTrackingOnLocationChange
        string _location = (akNewLoc as Form).GetName()
        if _location == ""
            _location = "Skyrim"
        endIf
        AddIngameEventToConversation("The location is now " + _location)
    endIf
endEvent


Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
    if repository.playerTrackingOnObjectEquipped
        string itemEquipped = akBaseObject.getname()

        if (itemEquipped != "Mantella") && (itemEquipped != "Mantella Remove NPC") && (itemEquipped != "Mantella End Conversation")
            ;Debug.MessageBox("The player equipped " + itemEquipped)
            AddIngameEventToConversation(getPlayerName() + " equipped " + itemEquipped)
        endIf
    endif
endEvent


Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
    if repository.playerTrackingOnObjectUnequipped
        string itemUnequipped = akBaseObject.getname()

        if (itemUnequipped != "Mantella") && (itemUnequipped != "Mantella Remove NPC") && (itemUnequipped != "Mantella End Conversation")
            ;Debug.MessageBox("The player unequipped " + itemUnequipped)
            AddIngameEventToConversation(getPlayerName() + " unequipped " + itemUnequipped )
        endIf
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

