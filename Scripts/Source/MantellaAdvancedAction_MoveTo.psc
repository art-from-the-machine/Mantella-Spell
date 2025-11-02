Scriptname MantellaAdvancedAction_MoveTo extends Quest Hidden 

Actor Property PlayerRef Auto
MantellaRepository property repository Auto
MantellaConstants property mConsts Auto
MantellaInterface property EventInterface Auto
Faction Property MantellaFunctionSourceFaction Auto
Package Property MantellaMoveToPackage Auto
ReferenceAlias Property MoveToTargetAlias Auto

int _usedAliasCount = 0
bool[] _wasWaitingBeforeMove ; Track wait states to restore after movement

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_MOVETO, "OnNpcMoveToAdvancedActionReceived")
EndEvent


event OnNpcMoveToAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)
    MantellaConversation conversation = conversationQuest as MantellaConversation
    
    ; Extract NPC names from parameters
    string[] sourceNames = SKSE_HTTP.getStringArray(argumentsHandle, mConsts.ACTION_ARG_SOURCE)
    string targetName = SKSE_HTTP.getString(argumentsHandle, mConsts.ACTION_ARG_TARGET)

    ; Only one target supported for move to action
    Actor targetActor = conversation.GetActorByName(targetName)
    if targetActor
        MoveToTargetAlias.ForceRefTo(targetActor)
        
        ; Reset tracking
        _usedAliasCount = 0
        int numSources = sourceNames.Length
        if numSources > 12
            numSources = 12  ; Cap at available aliases
        endif
        
        ; Track moving actors and their wait states
        Actor[] movingActors = new Actor[12]
        _wasWaitingBeforeMove = new bool[12]
        
        ; Resolve each name to an Actor reference and start movement
        int i = 0
        While i < numSources
            Actor sourceActor = conversation.GetActorByName(sourceNames[i])
            if sourceActor
                NpcMoveTo(sourceActor, targetActor, i)
                movingActors[i] = sourceActor
            endif
            i += 1
        EndWhile

        ; Wait for actors to reach destination
        WaitForMovement(targetActor, movingActors, numSources)
        
        CleanupMoveTo()
    endIf
endEvent


Function NpcMoveTo(Actor source, Actor target, int aliasIndex)
    if (source && target)
        Debug.Notification(source.GetDisplayName() + " moves to " + target.GetDisplayName() + ".")
        
        ; Store wait state to restore it after movement
        bool wasWaiting = false
        if source.IsPlayerTeammate()
            wasWaiting = (source.GetActorValue("WaitingForPlayer") == 1)
            if wasWaiting
                ; Temporarily clear wait so the NPC can move
                source.SetActorValue("WaitingForPlayer", 0)
            endif
        endif
        ; Store wait state for restoration after movement completes
        _wasWaitingBeforeMove[aliasIndex] = wasWaiting
       
        ; Add to MoveTo faction
        source.SetFactionRank(MantellaFunctionSourceFaction, 1)
        
        ; Assign to specific alias which has the MoveTo package
        ReferenceAlias sourceAlias = self.GetNthAlias(aliasIndex) as ReferenceAlias
        sourceAlias.ForceRefTo(source)
        source.EvaluatePackage()
        
        _usedAliasCount += 1
    endif
EndFunction


Function WaitForMovement(Actor target, Actor[] movingActors, int numActors)
    float elapsedTime = 0.0
    float maxWaitTime = 30.0
    float checkInterval = 5.0
    
    While elapsedTime < maxWaitTime
        bool allNearTarget = true
        int i = 0
        
        ; Check if all actors are near the target
        While i < numActors
            if movingActors[i]
                float distance = movingActors[i].GetDistance(target)
                if distance > 256.0  ; Within default follow distance
                    allNearTarget = false
                endif
            endif
            i += 1
        EndWhile
        
        if allNearTarget
            return
        endif
        
        Utility.Wait(checkInterval)
        elapsedTime += checkInterval
    EndWhile
EndFunction


Function CleanupMoveTo()
    int i = 0
    While i < _usedAliasCount
        ReferenceAlias sourceAlias = GetNthAlias(i) as ReferenceAlias
        Actor a = sourceAlias.GetReference() as Actor
        if a
            ; Remove from MoveTo faction
            a.RemoveFromFaction(MantellaFunctionSourceFaction)
            
            ; Restore wait state if actor was waiting before movement
            if _wasWaitingBeforeMove[i] && a.IsPlayerTeammate()
                a.SetActorValue("WaitingForPlayer", 1)
            endif
            
            a.EvaluatePackage()
        endif
        sourceAlias.Clear()
        i += 1
    EndWhile
    
    MoveToTargetAlias.Clear()
    _usedAliasCount = 0
    _wasWaitingBeforeMove = None
EndFunction