Scriptname MantellaAdvancedAction_Unfollow extends Quest Hidden 

Actor Property PlayerRef Auto
MantellaConstants property mConsts Auto
MantellaInterface property EventInterface Auto
MantellaRepository Property repository Auto

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ACTIONS_PREFIX + mConsts.ACTION_NPC_UNFOLLOW, "OnNpcUnfollowActionReceived")
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_UNFOLLOW, "OnNpcUnfollowAdvancedActionReceived")
EndEvent


event OnNpcUnfollowActionReceived(Form speaker)
    Actor aSpeaker = speaker as Actor
    NpcUnfollow(aSpeaker)
endEvent


event OnNpcUnfollowAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)
    MantellaConversation conversation = conversationQuest as MantellaConversation
    
    ; Extract NPC names from parameters
    string[] sourceNames = SKSE_HTTP.getStringArray(argumentsHandle, mConsts.ACTION_ARG_SOURCE)
    
    ; Resolve each name to an Actor reference
    int i = 0
    While i < sourceNames.Length
        Actor sourceActor = conversation.GetActorByName(sourceNames[i])
        if sourceActor != none
            NpcUnfollow(sourceActor)
        endIf
        i += 1
    EndWhile
endEvent


Function NpcUnfollow(Actor speaker)
    if (speaker)
        Debug.Notification(speaker.GetDisplayName() + " stops following you.")
        speaker.SetActorValue("WaitingForPlayer", 0)
        MantellaFollowerUtils.DismissFollower(speaker, repository.gia_FollowerQst, repository.giafac_following)
    endif
EndFunction