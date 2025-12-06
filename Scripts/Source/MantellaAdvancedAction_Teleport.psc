Scriptname MantellaAdvancedAction_Teleport extends Quest Hidden 

MantellaInterface Property EventInterface Auto
MantellaConstants Property mConsts Auto
Actor Property PlayerRef Auto

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ACTIONS_PREFIX + mConsts.ACTION_NPC_TELEPORT, "OnNpcTeleportActionReceived")
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_TELEPORT, "OnNpcTeleportAdvancedActionReceived")
EndEvent

event OnNpcTeleportActionReceived(Form speaker)
    Actor sourceActor = speaker as Actor
    Debug.Notification(sourceActor.GetDisplayName() + " teleports to " + PlayerRef.GetDisplayName() + ".")
    sourceActor.MoveTo(PlayerRef)
endEvent


event OnNpcTeleportAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)
    MantellaConversation conversation = conversationQuest as MantellaConversation
    
    ; Extract NPC names from parameters
    string[] sourceNames = SKSE_HTTP.getStringArray(argumentsHandle, mConsts.ACTION_ARG_SOURCE)
    string targetName = SKSE_HTTP.getString(argumentsHandle, mConsts.ACTION_ARG_TARGET)

    ; Only one target supported for teleport action
    Actor targetActor = conversation.GetActorByName(targetName)

    if targetActor
        int i = 0
        While i < sourceNames.Length
            Actor sourceActor = conversation.GetActorByName(sourceNames[i])
            if sourceActor
                Debug.Notification(sourceNames[i] + " teleports to " + targetName + ".")
                sourceActor.MoveTo(targetActor)
            endif
            i += 1
        EndWhile
    endIf
endEvent