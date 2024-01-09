Scriptname MantellaTargetListenerScript extends ReferenceAlias
;new property added after Mantella 0.9.2
MantellaRepository property repository auto

;All the event listeners below have 'if' clauses added after Mantella 0.9.2 (except ondying)
Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    if repository.targetTrackingItemAdded 
        String selfName = self.GetActorReference().getdisplayname()
        string itemName = akBaseItem.GetName()
        string itemPickedUpMessage = selfName+" picked up " + itemName + ".\n"

        string sourceName = akSourceContainer.getbaseobject().getname()
        if sourceName != ""
            itemPickedUpMessage = selfName+" picked up " + itemName + " from " + sourceName + ".\n"
        endIf
        
        if (itemName != "Iron Arrow") && (itemName != "") ;Papyrus hallucinates iron arrows
            ;Debug.Notification(itemPickedUpMessage)
            MiscUtil.WriteToFile("_mantella_in_game_events.txt", itemPickedUpMessage)
        endIf
    endif
EndEvent


Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    if repository.targetTrackingItemRemoved  
        String selfName = self.GetActorReference().getdisplayname()
        string itemName = akBaseItem.GetName()
        string itemDroppedMessage = selfName+" dropped " + itemName + ".\n"

        string destName = akDestContainer.getbaseobject().getname()
        if destName != ""
            itemDroppedMessage = selfName+" placed " + itemName + " in/on " + destName + ".\n"
        endIf
        
        if  (itemName != "Iron Arrow") && (itemName != "") ; Papyrus hallucinates iron arrows
            ;Debug.Notification(itemDroppedMessage)
            MiscUtil.WriteToFile("_mantella_in_game_events.txt", itemDroppedMessage)
        endIf
    endif
endEvent


Event OnSpellCast(Form akSpell)
    if repository.targetTrackingOnSpellCast 
        String selfName = self.GetActorReference().getdisplayname()
        string spellCast = (akSpell as form).getname()
        if spellCast 
            ;Debug.Notification(selfName+" casted the spell "+ spellCast)
            MiscUtil.WriteToFile("_mantella_in_game_events.txt", selfName+" casted the spell " + spellCast + ".\n")
        endIf
    endif
endEvent


String lastHitSource = ""
String lastAggressor = ""
Int timesHitSameAggressorSource = 0
Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    if repository.targetTrackingOnSpellCast 
        String aggressor
        if akAggressor == Game.GetPlayer()
            aggressor = "The player"
        else
            aggressor = akAggressor.getdisplayname()
        endif
        string hitSource = akSource.getname()
        String selfName = self.GetActorReference().getdisplayname()

        ; avoid writing events too often (continuous spells record very frequently)
        ; if the actor and weapon hasn't changed, only record the event every 5 hits
        if ((hitSource != lastHitSource) && (aggressor != lastAggressor)) || (timesHitSameAggressorSource > 5)
            lastHitSource = hitSource
            lastAggressor = aggressor
            timesHitSameAggressorSource = 0

            if (hitSource == "None") || (hitSource == "")
                ;Debug.MessageBox(aggressor + " punched "+selfName+".")
                MiscUtil.WriteToFile("_mantella_in_game_events.txt", aggressor + " punched "+selfName+".\n")
            elseif hitSource == "Mantella"
                ; Do not save event if Mantella itself is cast
            else
                ;Debug.MessageBox(aggressor + " hit "+selfName+" with a(n) " + hitSource)
                MiscUtil.WriteToFile("_mantella_in_game_events.txt", aggressor + " hit "+selfName+" with " + hitSource+".\n")
            endIf
        else
            timesHitSameAggressorSource += 1
        endIf
    endif
EndEvent


Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
    if repository.targetTrackingOnCombatStateChanged
        String selfName = self.GetActorReference().getdisplayname()
        String targetName
        if akTarget == Game.GetPlayer()
            targetName = "the player"
        else
            targetName = akTarget.getdisplayname()
        endif

        if (aeCombatState == 0)
            ;Debug.MessageBox(selfName+" is no longer in combat")
            MiscUtil.WriteToFile("_mantella_in_game_events.txt", selfName+" is no longer in combat.\n")
            MiscUtil.WriteToFile("_mantella_actor_is_in_combat.txt", "False", append=false)
        elseif (aeCombatState == 1)
            ;Debug.MessageBox(selfName+" has entered combat with "+targetName)
            MiscUtil.WriteToFile("_mantella_in_game_events.txt", selfName+" has entered combat with "+targetName+".\n")
            MiscUtil.WriteToFile("_mantella_actor_is_in_combat.txt", "True", append=false)
        elseif (aeCombatState == 2)
            ;Debug.MessageBox(selfName+" is searching for "+targetName)
            MiscUtil.WriteToFile("_mantella_in_game_events.txt", selfName+" is searching for "+targetName+".\n")
        endIf
    endif
endEvent


Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
    if repository.targetTrackingOnObjectEquipped
        String selfName = self.GetActorReference().getdisplayname()
        string itemEquipped = akBaseObject.getname()
        ;Debug.MessageBox(selfName+" equipped " + itemEquipped)
        MiscUtil.WriteToFile("_mantella_in_game_events.txt", selfName+" equipped " + itemEquipped + ".\n")
    endif
endEvent


Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
    if repository.targetTrackingOnObjectUnequipped
        String selfName = self.GetActorReference().getdisplayname()
        string itemUnequipped = akBaseObject.getname()
        ;Debug.MessageBox(selfName+" unequipped " + itemUnequipped)
        MiscUtil.WriteToFile("_mantella_in_game_events.txt", selfName+" unequipped " + itemUnequipped + ".\n")
    endif
endEvent


Event OnSit(ObjectReference akFurniture)
    if repository.targetTrackingOnSit
        String selfName = self.GetActorReference().getdisplayname()
        ;Debug.MessageBox(selfName+" sat down.")
        String furnitureName = akFurniture.getbaseobject().getname()
        ; only save event if actor is sitting / resting on furniture (and not just, for example, leaning on a bar table)
        if furnitureName != ""
            MiscUtil.WriteToFile("_mantella_in_game_events.txt", selfName+" rested on / used a(n) "+furnitureName+".\n")
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
            MiscUtil.WriteToFile("_mantella_in_game_events.txt", selfName+" stood up from a(n) "+furnitureName+".\n")
        endIf
    endif
EndEvent


Event OnDying(Actor akKiller)
    MiscUtil.WriteToFile("_mantella_end_conversation.txt", "True",  append=false)
EndEvent
