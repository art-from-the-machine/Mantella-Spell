Scriptname MantellaAdvancedAction_Barter extends Quest Hidden 

MantellaConstants property mConsts auto
MantellaInterface property EventInterface Auto

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ACTIONS_PREFIX + mConsts.ACTION_NPC_BARTER, "OnNpcBarterActionReceived")
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_BARTER, "OnNpcBarterAdvancedActionReceived")
EndEvent

event OnNpcBarterActionReceived(Form speaker)
    Actor sourceActor = speaker as Actor
    NpcBarter(sourceActor)
endEvent


event OnNpcBarterAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)
    MantellaConversation conversation = conversationQuest as MantellaConversation
    
    ; Extract NPC name from parameter
    string sourceName = SKSE_HTTP.getString(argumentsHandle, mConsts.ACTION_ARG_SOURCE)
    ; Only one NPC can open their barter menu per response
    Actor sourceActor = conversation.GetActorByName(sourceName)

    NpcBarter(sourceActor)
endEvent


Function NpcBarter(Actor source)
    if source
        source.ShowBarterMenu()
        EventInterface.AddMantellaEvent(source.GetDisplayName() + "'s barter menu opened.")
    endif
EndFunction