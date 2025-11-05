Scriptname MantellaAdvancedAction_Loot extends Quest Hidden 

MantellaInterface Property EventInterface Auto
Faction Property MantellaFunctionSourceFaction Auto
Package Property MantellaLootPackage Auto
MantellaConstants Property mConsts Auto
Quest Property MantellaLootAnyQuest Auto

int _usedAliasCount = 0
int _numUpdates = 0

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_LOOT, "OnNpcLootAdvancedActionReceived")
EndEvent


event OnNpcLootAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)
    MantellaConversation conversation = conversationQuest as MantellaConversation

    MantellaLootAnyQuest.Start()
    
    ; Extract NPC names from parameters
    string[] sourceNames = SKSE_HTTP.getStringArray(argumentsHandle, mConsts.ACTION_ARG_SOURCE)

    ; Reset tracking
    _usedAliasCount = 0
    int numSources = sourceNames.Length
    if numSources > 5
        numSources = 5  ; Cap at available aliases
    endif
    
    ; Resolve each name to an Actor reference and start looting
    int i = 0
    While i < numSources
        Actor sourceActor = conversation.GetActorByName(sourceNames[i])
        if sourceActor
            NpcLoot(sourceActor, i)
        endif
        i += 1
    EndWhile

    RegisterForSingleUpdate(10)
endEvent


Function NpcLoot(Actor source, int aliasIndex)
    if (source)
        Debug.Notification(source.GetDisplayName() + " starts looting.")

        if source.IsPlayerTeammate()
            if (source.GetActorValue("WaitingForPlayer") == 1)
                ; Clear wait so the NPC can move
                source.SetActorValue("WaitingForPlayer", 0)
            endif
        endif
        
        ; Add to Loot faction
        source.SetFactionRank(MantellaFunctionSourceFaction, 3)

        ; Assign to specific alias which has the Loot package
        ReferenceAlias sourceAlias = MantellaLootAnyQuest.GetNthAlias(aliasIndex) as ReferenceAlias
        sourceAlias.ForceRefTo(source)
        source.EvaluatePackage()
        
        _usedAliasCount += 1
    endif
EndFunction


Event OnUpdate()
    int i = 0
    if _numUpdates >= 3
        CleanupLoot()
    else
        _numUpdates += 1
        RegisterForSingleUpdate(10)
    endif
EndEvent


Function CleanupLoot()
    int i = 0
    While i < _usedAliasCount
        ReferenceAlias sourceAlias = MantellaLootAnyQuest.GetNthAlias(i) as ReferenceAlias
        Actor a = sourceAlias.GetReference() as Actor
        if a
            ; Remove from Loot faction
            a.RemoveFromFaction(MantellaFunctionSourceFaction)
            Debug.Notification(a.GetDisplayName() + " finished looting.")
            
            a.EvaluatePackage()
        endif
        i += 1
    EndWhile

    MantellaLootAnyQuest.Stop()

    _usedAliasCount = 0
    _numUpdates = 0
EndFunction