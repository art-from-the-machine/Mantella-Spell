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
        AddAuthoritativeInventorySnapshot(source)
        source.OpenInventory(true)
        EventInterface.AddMantellaEvent(source.GetDisplayName() + "'s inventory opened.")
    else
        EventInterface.AddMantellaEvent("Inventory failed: the requested NPC could not be found.")
    endif
    EventInterface.MarkActionResponseCompleted(mConsts.ACTION_NPC_INVENTORY)
EndFunction

Function AddAuthoritativeInventorySnapshot(Actor source)
    string snapshot = ""
    int namedItemCount = 0
    int itemIndex = 0
    int itemTotal = source.GetNumItems()
    While itemIndex < itemTotal && namedItemCount < 40
        Form itemForm = source.GetNthForm(itemIndex)
        if itemForm && source.GetItemCount(itemForm) > 0 && itemForm.GetName() != ""
            if snapshot != ""
                snapshot += ", "
            endIf
            snapshot += itemForm.GetName()
            int count = source.GetItemCount(itemForm)
            if count > 1
                snapshot += " x" + count
            endIf
            namedItemCount += 1
        endIf
        itemIndex += 1
    EndWhile

    if snapshot == ""
        snapshot = "no named items"
    elseIf itemIndex < itemTotal
        snapshot += ", and additional items not listed"
    endIf
    EventInterface.AddMantellaEvent("Authoritative Skyrim inventory for " + source.GetDisplayName() + " at action time: " + snapshot + ".")
EndFunction
