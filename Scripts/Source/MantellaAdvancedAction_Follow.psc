Scriptname MantellaAdvancedAction_Follow extends Quest hidden

Actor Property PlayerRef Auto
MantellaRepository property repository auto
MantellaConstants property mConsts auto
MantellaInterface property EventInterface Auto

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_FOLLOW, "OnNpcFollowAdvancedActionReceived")
EndEvent

event OnNpcFollowAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)
    MantellaConversation conversation = conversationQuest as MantellaConversation
    
    ; Extract NPC names from parameters
    string[] sourceNames = SKSE_HTTP.getStringArray(argumentsHandle, mConsts.ACTION_ARG_SOURCE)
    
    ; Resolve each name to an Actor reference
    int i = 0
    While i < sourceNames.Length
        Actor sourceActor = conversation.GetActorByName(sourceNames[i])
        if sourceActor != none
            NpcFollow(sourceActor)
        endIf
        i += 1
    EndWhile
endEvent

Function NpcFollow(Actor speaker)
    if (speaker)
        if (speaker.getrelationshiprank(PlayerRef) != "4")
            if PlayerRef.isinfaction(repository.giafac_allowfollower)
                Debug.Notification(speaker.GetDisplayName() + " is following you.")
                speaker.SetFactionRank(repository.giafac_following, 1)
                repository.gia_FollowerQst.reset()
                repository.gia_FollowerQst.stop()
                Utility.Wait(0.5)
                repository.gia_FollowerQst.start()
                speaker.EvaluatePackage()
            else
                Debug.Notification("Follow action not enabled in the Mantella MCM.")
            endif
        endif
    endif
EndFunction