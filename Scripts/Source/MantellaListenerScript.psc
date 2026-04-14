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

Actor Property RecentActor1 Auto Hidden
Actor Property RecentActor2 Auto Hidden
Actor Property RecentActor3 Auto Hidden
Actor Property RecentActor4 Auto Hidden
Actor Property RecentActor5 Auto Hidden



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


bool Function IsOnCooldown(Actor akActor)
    ; Checks whether an actor is in the recent cooldown list.
    ; Returns true if the actor matches any of the 5 RecentActor slots.
    return akActor == RecentActor1 || akActor == RecentActor2 || akActor == RecentActor3 || akActor == RecentActor4 || akActor == RecentActor5
EndFunction

Function AddToCooldown(Actor akActor)
    ; Adds an actor to the cooldown list using a shift-down pattern.
    ; The most recently added actor is always in slot 1, and the oldest is pushed out of slot 5.
    if akActor
        RecentActor5 = RecentActor4
        RecentActor4 = RecentActor3
        RecentActor3 = RecentActor2
        RecentActor2 = RecentActor1
        RecentActor1 = akActor
        ; if repository.showRadiantDialogueMessages
        ;     Debug.Notification("Cooldown added: " + akActor.GetDisplayName())
        ; endIf
    endIf
EndFunction

Function ClearCooldown()
    ; Resets all cooldown slots to None.
    ; Called when all nearby NPCs are on cooldown, so conversations can start fresh.
    RecentActor1 = None
    RecentActor2 = None
    RecentActor3 = None
    RecentActor4 = None
    RecentActor5 = None
    ; if repository.showRadiantDialogueMessages
    ;     Debug.Notification("Cooldown list cleared")
    ; endIf
EndFunction

Actor[] Function CollectEligibleActors(Actor referenceActor, float maxDistance)
    ; Gathers all PotentialActors from the actor picker that are within maxDistance of the referenceActor.
    ; Actors currently in the cooldown list are excluded.
    ; Returns an Actor[5] array where None entries indicate empty slots.
    Actor[] eligible = new Actor[5]
    int count = 0

    Actor[] candidates = new Actor[5]
    if PotentialActor1.GetReference() as Actor
        candidates[0] = PotentialActor1.GetReference() as Actor
    endIf
    if PotentialActor2.GetReference() as Actor
        candidates[1] = PotentialActor2.GetReference() as Actor
    endIf
    if PotentialActor3.GetReference() as Actor
        candidates[2] = PotentialActor3.GetReference() as Actor
    endIf
    if PotentialActor4.GetReference() as Actor
        candidates[3] = PotentialActor4.GetReference() as Actor
    endIf
    if PotentialActor5.GetReference() as Actor
        candidates[4] = PotentialActor5.GetReference() as Actor
    endIf

    int i = 0
    while i < 5
        if candidates[i]
            float dist = referenceActor.GetDistance(candidates[i])
            if dist <= maxDistance
                if !IsOnCooldown(candidates[i])
                    eligible[count] = candidates[i]
                    count += 1
                endIf
            endIf
        endIf
        i += 1
    endWhile

    if repository.showRadiantDialogueMessages
        Debug.Notification("Eligible Radiant NPCs found: " + count)
    endIf

    return eligible
EndFunction

int Function CountActors(Actor[] actors)
    ; Counts the number of non-None entries in an actor array.
    int count = 0
    int i = 0
    while i < actors.Length
        if actors[i]
            count += 1
        endIf
        i += 1
    endWhile
    return count
EndFunction

Actor Function PickRandomActor(Actor[] actors)
    ; Picks a random non-None actor from the array using Utility.RandomInt.
    ; Returns None if the array is empty.
    int count = CountActors(actors)
    if count == 0
        return None
    endIf
    int target = Utility.RandomInt(0, count - 1)
    int seen = 0
    int i = 0
    while i < actors.Length
        if actors[i]
            if seen == target
                return actors[i]
            endIf
            seen += 1
        endIf
        i += 1
    endWhile
    return None
EndFunction

Function RemoveActorFromArray(Actor[] actors, Actor toRemove)
    ; Sets matching entries in the array to None, so subsequent random picks will not select the same actor.
    int i = 0
    while i < actors.Length
        if actors[i] == toRemove
            actors[i] = None
        endIf
        i += 1
    endWhile
EndFunction

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
                Debug.Notification("NPCs too far away at " + ConvertGameUnitsToMeter(distanceFromPlayerToClosestActor) + " meters")
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
                float maxDistance = ConvertMeterToGameUnits(repository.radiantDistance)

                ; Collect eligible actors within radiant distance, filtering out recently used NPCs
                Actor[] eligible = CollectEligibleActors(PlayerRef, maxDistance)
                int eligibleCount = CountActors(eligible)

                ; If fewer than 2 eligible, clear cooldown and retry without filter
                if eligibleCount < 2
                    ClearCooldown()
                    eligible = CollectEligibleActors(PlayerRef, maxDistance)
                    eligibleCount = CountActors(eligible)
                endIf

                if eligibleCount >= 2
                    ; Randomly pick the two initiator NPCs
                    Actor Actor1 = PickRandomActor(eligible)
                    RemoveActorFromArray(eligible, Actor1)
                    Actor Actor2 = PickRandomActor(eligible)
                    RemoveActorFromArray(eligible, Actor2)

                    Actor[] actors = new Actor[5]
                    actors[0] = Actor1
                    actors[1] = Actor2

                    ; For each remaining eligible NPC, coin flip to include them
                    int slot = 2
                    int i = 0
                    while i < eligible.Length && slot < 5
                        if eligible[i] && Utility.RandomInt(0, 1) == 1
                            actors[slot] = eligible[i]
                            slot += 1
                        endIf
                        i += 1
                    endWhile

                    ; Only cooldown the two initiators
                    AddToCooldown(Actor1)
                    AddToCooldown(Actor2)

                    Debug.Notification("Starting conversation...")
                    conversation.Start()
                    conversation.StartConversation(actors)
                elseif(repository.showRadiantDialogueMessages)
                    Debug.Notification("Radiant dialogue attempted. No NPCs available")
                endIf
            elseIf repository.approachEnabled
                float maxDistance = ConvertMeterToGameUnits(repository.radiantDistance)

                ; Collect eligible actors within range, filtering out recently used NPCs
                Actor[] eligible = CollectEligibleActors(PlayerRef, maxDistance)
                int eligibleCount = CountActors(eligible)

                ; If none eligible, clear cooldown and retry
                if eligibleCount < 1
                    ClearCooldown()
                    eligible = CollectEligibleActors(PlayerRef, maxDistance)
                    eligibleCount = CountActors(eligible)
                endIf

                if eligibleCount >= 1
                    Actor chosenActor = PickRandomActor(eligible)

                    Actor[] actors = new Actor[2]
                    actors[0] = PlayerRef
                    actors[1] = chosenActor

                    AddToCooldown(chosenActor)

                    conversation.Start()
                    Debug.Notification(chosenActor.GetDisplayName() + " approaches...")
                    conversation.AddIngameEvent(chosenActor.GetDisplayName() + " approaches " + getPlayerName(False) + " with something on their mind.")
                    conversation.StartConversation(actors)
                    conversation.TriggerApproachMoveAction(chosenActor)
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

