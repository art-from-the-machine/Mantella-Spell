Scriptname MantellaAdvancedAction_Flee extends Quest Hidden 

MantellaConstants property mConsts Auto
MantellaInterface property EventInterface Auto
ReferenceAlias Property FleeTargetAlias Auto
Faction Property MantellaFunctionSourceFaction Auto
GlobalVariable Property MantellaFleeExpireTime Auto
GlobalVariable Property GameDaysPassed Auto

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_FLEE, "OnNpcFleeAdvancedActionReceived")
EndEvent


event OnNpcFleeAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)
    MantellaConversation conversation = conversationQuest as MantellaConversation
    
    ; Extract NPC names from parameters
    string[] sourceNames = SKSE_HTTP.getStringArray(argumentsHandle, mConsts.ACTION_ARG_SOURCE)
    string targetName = SKSE_HTTP.getString(argumentsHandle, mConsts.ACTION_ARG_TARGET)

    ; Only one target supported for move to action
    Actor targetActor = conversation.GetActorByName(targetName)
    if targetActor
        FleeTargetAlias.ForceRefTo(targetActor)
        
        ; Reset tracking
        int numSources = sourceNames.Length
        if numSources > 12
            numSources = 12  ; Cap at available aliases
        endif
        
        ; Track moving actors and their wait states
        Actor[] movingActors = new Actor[12]
        
        ; Resolve each name to an Actor reference and start fleeing
        int i = 0
        While i < numSources
            Actor sourceActor = conversation.GetActorByName(sourceNames[i])
            if sourceActor
                NpcFlee(sourceActor, targetActor, i)
                movingActors[i] = sourceActor
            endif
            i += 1
        EndWhile
    endIf
endEvent


Function NpcFlee(Actor source, Actor target, int aliasIndex)
    if (source && target)
        Debug.Notification(source.GetDisplayName() + " flees from " + target.GetDisplayName() + ".")

        ; Set to flee for 1 Skyrim hour (1/24 = 0.042 days)
        MantellaFleeExpireTime.SetValue(GameDaysPassed.GetValue() + 0.042)

        source.StopCombat()
        Utility.Wait(0.5)
       
        ; Add to Flee faction
        source.SetFactionRank(MantellaFunctionSourceFaction, 4) ; 4 = Flee faction
        
        ; Assign to specific alias which has the Flee package
        ReferenceAlias sourceAlias = self.GetNthAlias(aliasIndex) as ReferenceAlias
        sourceAlias.ForceRefTo(source)
        Utility.Wait(0.5)
        source.EvaluatePackage()
    endif
EndFunction