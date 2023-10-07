Scriptname MantellaTargetListenerScript extends ReferenceAlias

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    String selfName = (self.GetActorReference().getleveledactorbase() as form).getname()
    string itemName = akBaseItem.GetName()
    string itemPickedUpMessage = selfName+" picked up " + itemName + ".\n"
    
    if (itemName != "Iron Arrow") && (itemName != "") ; Papyrus hallucinates iron arrows
        ;Debug.Notification(itemPickedUpMessage)
        MiscUtil.WriteToFile("_mantella_in_game_events.txt", itemPickedUpMessage)
    endIf
EndEvent


Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    String selfName = (self.GetActorReference().getleveledactorbase() as form).getname()
    string itemName = akBaseItem.GetName()
    string itemDroppedMessage = selfName+" dropped " + itemName + ".\n"
    
    if  (itemName != "Iron Arrow") && (itemName != "") ; Papyrus hallucinates iron arrows
        ;Debug.Notification(itemDroppedMessage)
        MiscUtil.WriteToFile("_mantella_in_game_events.txt", itemDroppedMessage)
    endIf
endEvent


Event OnSpellCast(Form akSpell)
    String selfName = (self.GetActorReference().getleveledactorbase() as form).getname()
    string spellCast = (akSpell as form).getname()
    if spellCast
        ;Debug.Notification(selfName+" casted the spell "+ spellCast)
        MiscUtil.WriteToFile("_mantella_in_game_events.txt", selfName+" casted the spell " + spellCast + ".\n")
    endIf
endEvent


String lastHitSource = ""
String lastAggressor = ""
Int timesHitSameAggressorSource = 0
Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    String aggressor
    if akAggressor == Game.GetPlayer()
        aggressor = "The player"
    else
        aggressor = akAggressor.getdisplayname()
    endif
    string hitSource = akSource.getname()
    String selfName = (self.GetActorReference().getleveledactorbase() as form).getname()

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
            ; Do not write
        else
            ;Debug.MessageBox(aggressor + " hit "+selfName+" with a(n) " + hitSource)
            MiscUtil.WriteToFile("_mantella_in_game_events.txt", aggressor + " hit "+selfName+" with " + hitSource+".\n")
        endIf
    else
        timesHitSameAggressorSource += 1
    endIf
EndEvent


Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
    String targetName
    String selfName = (self.GetActorReference().getleveledactorbase() as form).getname()
    
    if akTarget == Game.GetPlayer()
        targetName = "the player"
    else
        targetName = (akTarget.getleveledactorbase() as form).getname()
    endif

    if (aeCombatState == 0)
        ;Debug.MessageBox(selfName+" is no longer in combat")
        MiscUtil.WriteToFile("_mantella_in_game_events.txt", selfName+" is no longer in combat.\n")
    elseif (aeCombatState == 1)
        ;Debug.MessageBox(selfName+" has entered combat with "+targetName)
        MiscUtil.WriteToFile("_mantella_in_game_events.txt", selfName+" has entered combat with "+targetName+".\n")
    elseif (aeCombatState == 2)
        ;Debug.MessageBox(selfName+" is searching for "+targetName)
        MiscUtil.WriteToFile("_mantella_in_game_events.txt", selfName+" is searching for "+targetName+".\n")
    endIf
endEvent


Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
    String selfName = (self.GetActorReference().getleveledactorbase() as form).getname()
    string itemEquipped = akBaseObject.getname()
    ;Debug.MessageBox(selfName+" equipped " + itemEquipped)
    MiscUtil.WriteToFile("_mantella_in_game_events.txt", selfName+" equipped " + itemEquipped + ".\n")
endEvent


Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
    String selfName = (self.GetActorReference().getleveledactorbase() as form).getname()
    string itemUnequipped = akBaseObject.getname()
    ;Debug.MessageBox(selfName+" unequipped " + itemUnequipped)
    MiscUtil.WriteToFile("_mantella_in_game_events.txt", selfName+" unequipped " + itemUnequipped + ".\n")
endEvent


Event OnSit(ObjectReference akFurniture)
    String selfName = (self.GetActorReference().getleveledactorbase() as form).getname()
    ;Debug.MessageBox(selfName+" sat down.")
    MiscUtil.WriteToFile("_mantella_in_game_events.txt", selfName+" sat down.\n")
endEvent


Event OnGetUp(ObjectReference akFurniture)
    String selfName = (self.GetActorReference().getleveledactorbase() as form).getname()
    ;Debug.MessageBox(selfName+" stood up.")
    MiscUtil.WriteToFile("_mantella_in_game_events.txt", selfName+" stood up.\n")
EndEvent


Event OnDying(Actor akKiller)
    MiscUtil.WriteToFile("_mantella_end_conversation.txt", "True",  append=false)
EndEvent