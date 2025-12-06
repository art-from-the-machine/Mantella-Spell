Scriptname MantellaAdvancedAction_CollectIngr extends Quest Hidden

MantellaInterface Property EventInterface Auto
MantellaConstants Property mConsts Auto
Faction Property MantellaFunctionSourceFaction Auto
Quest Property MantellaCollectIngredientsQuest Auto
ReferenceAlias Property MantellaCollectableItem1 Auto

int _usedAliasCount

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ACTIONS_PREFIX + mConsts.ACTION_NPC_COLLECTINGREDIENTS, "OnNpcCollectIngredientsActionReceived")
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_COLLECTINGREDIENTS, "OnNpcCollectIngredientsAdvancedActionReceived")
EndEvent

event OnNpcCollectIngredientsActionReceived(Form speaker)
    MantellaCollectIngredientsQuest.Start()
    _usedAliasCount = 1

    Actor sourceActor = speaker as Actor
    NpcCollectIngredients(sourceActor, 0)
    
    RegisterForSingleUpdate(60)
endEvent


event OnNpcCollectIngredientsAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)
    MantellaConversation conversation = conversationQuest as MantellaConversation

    MantellaCollectIngredientsQuest.Start()
    
    ; Extract NPC names from parameters
    string[] sourceNames = SKSE_HTTP.getStringArray(argumentsHandle, mConsts.ACTION_ARG_SOURCE)

    ; Reset tracking
    _usedAliasCount = 0
    int numSources = sourceNames.Length
    if numSources > 5
        numSources = 5 ; Cap at available aliases
    endif
    
    ; Resolve each name to an Actor reference and start collecting ingredients
    int i = 0
    While i < numSources
        Actor sourceActor = conversation.GetActorByName(sourceNames[i])
        if sourceActor
            NpcCollectIngredients(sourceActor, i)
        endif
        i += 1
    EndWhile

    RegisterForSingleUpdate(60)
endEvent


Function NpcCollectIngredients(Actor source, int aliasIndex)
    if (source)
        Debug.Notification(source.GetDisplayName() + " starts collecting ingredients.")

        if source.IsPlayerTeammate()
            if (source.GetActorValue("WaitingForPlayer") == 1)
                ; Clear wait so the NPC can move
                source.SetActorValue("WaitingForPlayer", 0)
            endif
        endif
        
        ; Add to Collect faction
        source.SetFactionRank(MantellaFunctionSourceFaction, 7)

        ; Assign to specific alias which has the Collect package
        ReferenceAlias sourceAlias = MantellaCollectIngredientsQuest.GetNthAlias(aliasIndex) as ReferenceAlias
        sourceAlias.ForceRefTo(source)
        source.EvaluatePackage()
        
        _usedAliasCount += 1
    endif
EndFunction


Event OnUpdate()
    CleanupCollectIngredients()
EndEvent


Function CleanupCollectIngredients()
    int i = 0
    While i < _usedAliasCount
        ReferenceAlias sourceAlias = MantellaCollectIngredientsQuest.GetNthAlias(i) as ReferenceAlias
        Actor a = sourceAlias.GetReference() as Actor
        if a
            ; Remove from Collect faction
            a.RemoveFromFaction(MantellaFunctionSourceFaction)
            Debug.Notification(a.GetDisplayName() + " finished collecting ingredients.")
            
            a.EvaluatePackage()
        endif
        i += 1
    EndWhile

    MantellaCollectIngredientsQuest.Stop()
EndFunction