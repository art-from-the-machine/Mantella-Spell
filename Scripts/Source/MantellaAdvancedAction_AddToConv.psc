Scriptname MantellaAdvancedAction_AddToConv extends Quest Hidden 

Actor Property PlayerRef Auto
MantellaConstants property mConsts auto
MantellaInterface property EventInterface Auto

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_ADDTOCONVERSATION, "OnNpcAddToConversationAdvancedActionReceived")
EndEvent


event OnNpcAddToConversationAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)
    MantellaConversation conversation = conversationQuest as MantellaConversation
    int maxActors = 5
    
    ; Extract NPC names from parameters
    string[] sourceNames = SKSE_HTTP.getStringArray(argumentsHandle, mConsts.ACTION_ARG_SOURCE)
    Actor[] sourceActors = new Actor[5]

    ; Resolve each name to an Actor reference
    int i = 0
    While (i < sourceNames.Length) && (i < maxActors)
        Actor sourceActor = conversation.GetActorByName(sourceNames[i])
        if sourceActor
            Debug.Notification("Adding " + sourceNames[i] + " to conversation...")
            sourceActors[i] = sourceActor
        endif
        i += 1
    EndWhile

    conversation.AddActorsToConversation(sourceActors)
endEvent