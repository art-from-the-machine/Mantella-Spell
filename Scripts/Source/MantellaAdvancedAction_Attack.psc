Scriptname MantellaAdvancedAction_Attack extends Quest hidden

Actor Property PlayerRef Auto
MantellaRepository property repository auto
MantellaConstants property mConsts auto
MantellaInterface property EventInterface Auto

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_OFFENDED, "OnNpcAttackAdvancedActionReceived")
EndEvent


event OnNpcAttackAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)
    MantellaConversation conversation = conversationQuest as MantellaConversation
    
    ; Extract NPC names from parameters
    string[] sourceNames = SKSE_HTTP.getStringArray(argumentsHandle, mConsts.ACTION_ARG_SOURCE)
    string[] targetNames = SKSE_HTTP.getStringArray(argumentsHandle, mConsts.ACTION_ARG_TARGET)

    ; Only one target supported for attack action
    Actor targetActor = conversation.GetActorInConversation(targetNames[0])

    ; Resolve each name to an Actor reference
    int i = 0
    While i < sourceNames.Length
        Actor sourceActor = conversation.GetActorInConversation(sourceNames[i])
        if sourceActor != none
            NpcAttack(sourceActor, targetActor)
        endIf
        i += 1
    EndWhile
endEvent


Function NpcAttack(Actor source, Actor target)
    if (source && target)
        if PlayerRef.isinfaction(repository.giafac_AllowAnger)
            Debug.Notification(source.GetDisplayName() + " did not like that.")
            
            ; Add to opposing factions
            source.AddToFaction(repository.MantellaCombatTeamA)
            source.SetFactionRank(repository.MantellaCombatTeamA, 1)
            target.AddToFaction(repository.MantellaCombatTeamB)
            target.SetFactionRank(repository.MantellaCombatTeamB, 1)

            ; Wait for factions to register
            Utility.Wait(0.5)
            source.StartCombat(target)
            
            ; Remove from factions after combat starts
            Utility.Wait(0.5)
            source.RemoveFromFaction(repository.MantellaCombatTeamA)
            target.RemoveFromFaction(repository.MantellaCombatTeamB)
        else
            Debug.Notification("Aggro action not enabled in the Mantella MCM.")
        Endif
    endif
EndFunction