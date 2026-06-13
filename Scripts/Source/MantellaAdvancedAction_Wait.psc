Scriptname MantellaAdvancedAction_Wait extends Quest Hidden 

MantellaInterface Property EventInterface Auto
Faction Property MantellaFunctionSourceFaction Auto
MantellaConstants Property mConsts Auto
MantellaConversation Property conversation Auto
Actor Property PlayerRef Auto

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ACTIONS_PREFIX + mConsts.ACTION_NPC_WAIT, "OnNpcWaitActionReceived")
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_WAIT, "OnNpcWaitAdvancedActionReceived")
EndEvent

event OnNpcWaitActionReceived(Form speaker)
    int actorCount = 0
    if (conversation)
        actorCount = conversation.CountActorsInConversation()
    endif

    if (actorCount == 0)
        ; Conversation unavailable: fall back to the speaker only
        NpcWait(speaker as Actor)
        return
    endif

    ; Apply the wait action to every NPC in the conversation
    int i = 0
    While i < actorCount
        Actor participant = conversation.GetActorInConversationByIndex(i)
        if (participant && participant != PlayerRef)
            NpcWait(participant)
        endif
        i += 1
    EndWhile
endEvent


event OnNpcWaitAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)    
    ; Extract NPC names from parameters
    string[] sourceNames = SKSE_HTTP.getStringArray(argumentsHandle, mConsts.ACTION_ARG_SOURCE)

    ; Resolve each name to an Actor reference
    int i = 0
    While i < sourceNames.Length
        Actor sourceActor = conversation.GetActorByName(sourceNames[i])
        if sourceActor != none
            NpcWait(sourceActor)
        endIf
        i += 1
    EndWhile
endEvent


Function NpcWait(Actor source)
    if (source)
        Debug.Notification(source.GetDisplayName() + " is waiting.")
        source.SetActorValue("WaitingForPlayer", 1)
        source.EvaluatePackage()
    endif
EndFunction