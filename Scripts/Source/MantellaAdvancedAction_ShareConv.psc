Scriptname MantellaAdvancedAction_ShareConv extends Quest Hidden

MantellaConstants property mConsts auto
MantellaInterface property EventInterface Auto
Idle Property IdleDialogueHandOnChinGesture Auto

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_SHARECONVERSATION, "OnNpcShareConversationAdvancedActionReceived")
EndEvent


event OnNpcShareConversationAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)    
    string debugMessage = SKSE_HTTP.getString(argumentsHandle, "debug_message")
    Debug.Notification(debugMessage)
    EventInterface.AddMantellaEvent(debugMessage)
    
    bool succeeded = SKSE_HTTP.getBool(argumentsHandle, "recipient_succeeded")
    if succeeded
        Actor sourceActor = speaker as Actor
        if sourceActor
            sourceActor.PlayIdle(IdleDialogueHandOnChinGesture)
        endIf
    endIf

    EventInterface.MarkActionResponseCompleted(mConsts.ACTION_NPC_SHARECONVERSATION)
endEvent