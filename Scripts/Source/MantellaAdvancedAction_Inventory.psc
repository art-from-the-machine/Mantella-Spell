Scriptname MantellaAdvancedAction_Inventory extends Quest Hidden 

Actor Property PlayerRef Auto
MantellaRepository property repository auto
MantellaConstants property mConsts auto
MantellaInterface property EventInterface Auto

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_INVENTORY, "OnNpcInventoryAdvancedActionReceived")
EndEvent


event OnNpcInventoryAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)
    MantellaConversation conversation = conversationQuest as MantellaConversation
    
    ; Extract NPC names from parameters
    string sourceName = SKSE_HTTP.getString(argumentsHandle, mConsts.ACTION_ARG_SOURCE)
    ; Only one NPC can open their inventory per response
    Actor sourceActor = conversation.GetActorByName(sourceName)

    NpcInventory(sourceActor)
endEvent


Function NpcInventory(Actor source)
    if (source)
        if PlayerRef.isinfaction(repository.fac_AllowInventory)
            source.OpenInventory(true)
            EventInterface.AddMantellaEvent(source.GetDisplayName() + "'s inventory opened.")
        else
            Debug.Notification("Inventory action not enabled in the Mantella MCM.")
        endif
    endif
EndFunction