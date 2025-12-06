Scriptname MantellaAdvancedAction_StandDown extends Quest hidden

MantellaConstants property mConsts auto
MantellaInterface property EventInterface Auto
Faction Property MantellaFunctionSourceFaction Auto
Quest Property DGIntimidateQuest Auto

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_FORGIVEN, "OnNpcStandDownAdvancedActionReceived")
EndEvent


event OnNpcStandDownAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)
    MantellaConversation conversation = conversationQuest as MantellaConversation
    
    ; Extract NPC names from parameters
    string[] sourceNames = SKSE_HTTP.getStringArray(argumentsHandle, mConsts.ACTION_ARG_SOURCE)

    ; Resolve each name to an Actor reference
    int i = 0
    While i < sourceNames.Length
        Actor sourceActor = conversation.GetActorByName(sourceNames[i])
        if sourceActor != none
            NpcStandDown(sourceActor)
        endIf
        i += 1
    EndWhile

    if DGIntimidateQuest.IsRunning() ; End brawl quest if running
        DGIntimidateQuest.Stop()
    endif
endEvent


Function NpcStandDown(Actor source)
    if (source)
        Debug.Notification(source.GetDisplayName() + " ended combat.")
        source.StopCombat()

        if source.GetFactionRank(MantellaFunctionSourceFaction) == 4 ; 4 = Flee faction
            source.RemoveFromFaction(MantellaFunctionSourceFaction)
            source.EvaluatePackage()
        endIf
    endif
EndFunction