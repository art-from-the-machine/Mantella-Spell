Scriptname MantellaTargetListenerScript extends ReferenceAlias
;new property added after Mantella 0.9.2

Actor Property PlayerRef Auto
MantellaRepository property repository auto
MantellaConversation Property conversation auto
Form[] Property NPCTargets Auto

event OnInit()
    conversation = Quest.GetQuest("MantellaConversation") as MantellaConversation
    NPCTargets = Utility.CreateFormArray(0)
endEvent

Function AddIngameEventToConversation(string eventText)
    If (conversation.IsRunning())
        conversation.AddIngameEvent(eventText)
    EndIf
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

;All the event listeners below have 'if' clauses added after Mantella 0.9.2 (except ondying)
Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    if repository.targetTrackingItemAdded 
        String selfName = self.GetActorReference().getdisplayname()
        string itemName = akBaseItem.GetName()
        string itemCount = ""
        if itemName == "gold" ; only count the number of items if it is gold
            itemCount = aiItemCount+" "
        endIf
        string sourceName = ""
        if akSourceContainer != None
            sourceName = " from " + akSourceContainer.GetDisplayName()
        endif
        string itemPickedUpMessage = selfName + " picked up/took " + itemCount + itemName + sourceName         
        if (itemName != "Iron Arrow") && (itemName != "") && sourceName != PlayerRef.GetDisplayName() ;Papyrus hallucinates iron arrows
            ;Debug.Notification(itemPickedUpMessage)
            AddIngameEventToConversation(itemPickedUpMessage)
        endIf
    endif
EndEvent


Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    if repository.targetTrackingItemRemoved  
        String selfName = self.GetActorReference().getdisplayname()
        string itemName = akBaseItem.GetName()
        string itemCount = ""
        if itemName == "gold" ; only count the number of items if it is gold
            itemCount = aiItemCount+" "
        endIf
        string destName = ""
        if akDestContainer != None
            destName = " in/on/to " + akDestContainer.GetDisplayName()
        endif
        string itemDroppedMessage = selfName + " dropped/gave " + itemCount + itemName + destName 
        if  (itemName != "Iron Arrow") && (itemName != "") && destName != PlayerRef.GetDisplayName() ; Papyrus hallucinates iron arrows
            ;Debug.Notification(itemDroppedMessage)
            AddIngameEventToConversation(itemDroppedMessage)
        endIf
    endif
endEvent


Event OnSpellCast(Form akSpell)
    if repository.targetTrackingOnSpellCast 
        String selfName = self.GetActorReference().getdisplayname()
        string spellCast = (akSpell as form).getname()
        if spellCast && spellCast != "Mantella Placeholder Spell"
            ;Debug.Notification(selfName+" cast the spell "+ spellCast)
            AddIngameEventToConversation(selfName+" cast the spell " + spellCast )
        endIf
    endif
endEvent


String lastHitSource = ""
String lastAggressor = ""
Int timesHitSameAggressorSource = 0
Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    if repository.targetTrackingOnHit 
        String aggressor
        if akAggressor == PlayerRef
            aggressor = getPlayerName()
        else
            aggressor = akAggressor.getdisplayname()
        endif
        string hitSource = akSource.getname()
        String selfName = self.GetActorReference().getdisplayname()

        ; avoid writing events too often (continuous spells record very frequently)
        ; if the actor and weapon hasn't changed, only record the event every 5 hits
        if (((hitSource != lastHitSource) && (aggressor != lastAggressor)) || (timesHitSameAggressorSource > 5)) && ((hitSource != "Mantella") && (hitSource != "Mantella Remove NPC") && (hitSource != "Mantella End Conversation"))
            lastHitSource = hitSource
            lastAggressor = aggressor
            timesHitSameAggressorSource = 0

            if (hitSource == "None") || (hitSource == "")
                ;Debug.MessageBox(aggressor + " punched "+selfName+".")
                AddIngameEventToConversation(aggressor + " punched "+selfName)
            elseif hitSource == "Mantella"
                ; Do not save event if Mantella itself is cast
            else
                ;Debug.MessageBox(aggressor + " hit "+selfName+" with a(n) " + hitSource)
                AddIngameEventToConversation(aggressor + " hit "+selfName+" with " + hitSource)
            endIf
        else
            timesHitSameAggressorSource += 1
        endIf
    endif
EndEvent


Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
    if repository.targetTrackingOnCombatStateChanged
        Actor actorRef = self.GetActorReference()
        String selfName = actorRef.getdisplayname()
        String targetName

        if akTarget != None
            if akTarget == PlayerRef
                targetName = getPlayerName(False)
            else
                targetName = akTarget.getdisplayname()
            endif
        endif

        if (aeCombatState == 0)
            ; the NPC has exited combat - check if any of its targets were killed by the group
            int i = 0
            while i < NPCTargets.Length
                Actor target = NPCTargets[i] as Actor
                bool targetKilled = target.IsDead()
                Actor targetKiller = target.GetKiller()

                if targetKilled && targetKiller != None && (targetKiller == PlayerRef || targetKiller == actorRef)
                    AddIngameEventToConversation(target.getdisplayname() + " was killed by the group")
                endif
                i += 1
            endWhile

            ; remove all remaining NPC targets
            NPCTargets = Utility.CreateFormArray(0)
            AddIngameEventToConversation(selfName+" is no longer in combat")
        else
            ; the NPC has entered combat

            ; track the target, so that we can check if it was killed by the group when the NPC exits combat
            if NPCTargets.Find(akTarget) < 0
                NPCTargets = Utility.ResizeFormArray(NPCTargets, NPCTargets.Length + 1)
                NPCTargets[NPCTargets.Length - 1] = akTarget
            endif

            if (aeCombatState == 1)
                AddIngameEventToConversation(selfName+" has entered combat with "+targetName)
            elseif (aeCombatState == 2)
                AddIngameEventToConversation(selfName+" is searching for "+targetName)
            endIf
        endif
    endif
endEvent


Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
    if repository.targetTrackingOnObjectEquipped
        String selfName = self.GetActorReference().getdisplayname()
        string itemEquipped = akBaseObject.getname()
        ;Debug.MessageBox(selfName+" equipped " + itemEquipped)
        if itemEquipped != "Mantella Placeholder Spell"
            AddIngameEventToConversation(selfName+" equipped " + itemEquipped )
        endif
    endif
endEvent


Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
    if repository.targetTrackingOnObjectUnequipped
        String selfName = self.GetActorReference().getdisplayname()
        string itemUnequipped = akBaseObject.getname()
        ;Debug.MessageBox(selfName+" unequipped " + itemUnequipped)
        if itemUnequipped != "Mantella Placeholder Spell"
            AddIngameEventToConversation(selfName+" unequipped " + itemUnequipped )
        endif
    endif
endEvent


Event OnSit(ObjectReference akFurniture)
    if repository.targetTrackingOnSit
        String selfName = self.GetActorReference().getdisplayname()
        ;Debug.MessageBox(selfName+" sat down.")
        String furnitureName = akFurniture.getbaseobject().getname()
        ; only save event if actor is sitting / resting on furniture (and not just, for example, leaning on a bar table)
        if furnitureName != ""
            AddIngameEventToConversation(selfName+" rested on / used a(n) "+furnitureName)
        endIf
    endif
endEvent


Event OnGetUp(ObjectReference akFurniture)
    if  repository.targetTrackingOnGetUp
        String selfName = self.GetActorReference().getdisplayname()
        ;Debug.MessageBox(selfName+" stood up.")
        String furnitureName = akFurniture.getbaseobject().getname()
        ; only save event if actor is sitting / resting on furniture (and not just, for example, leaning on a bar table)
        if furnitureName != ""
            AddIngameEventToConversation(selfName+" stood up from a(n) "+furnitureName)
        endIf
    endif
EndEvent


Event OnDying(Actor akKiller)
    Debug.Notification(self.GetActorReference().getdisplayname() + " has died")
    String selfName = self.GetActorReference().getdisplayname()
    String killerName = ""

    if akKiller == None
        AddIngameEventToConversation(selfName + " died")
    else
        killerName = akKiller.getdisplayname()
        AddIngameEventToConversation(selfName + " was killed by " + killerName)
    EndIf

    If (conversation.IsRunning())
        Actor[] actors = new Actor[1]
        actors[0] = self.GetActorReference()
        conversation.RemoveActorsFromConversation(actors)
    EndIf
EndEvent
