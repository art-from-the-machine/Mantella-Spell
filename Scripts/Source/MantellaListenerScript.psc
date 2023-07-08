Scriptname MantellaListenerScript extends ReferenceAlias

Spell property MantellaSpell auto

event OnInit()
    Game.GetPlayer().AddSpell(MantellaSpell)
    Debug.MessageBox("Mantella spell added. Please save and reload to activate the mod.")
endEvent

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    string itemName = akBaseItem.GetName()
    string itemPickedUpMessage = "The player picked up " + itemName + ".\n"
    
    if itemName != "Iron Arrow" ; Papyrus hallucinates iron arrows
        ;Debug.MessageBox(itemPickedUpMessage)
        MiscUtil.WriteToFile("in_game_events.txt", itemPickedUpMessage)
    endIf
EndEvent

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    string itemName = akBaseItem.GetName()
    string itemDroppedMessage = "The player dropped " + itemName + ".\n"
    
    if itemName != "Iron Arrow" ; Papyrus hallucinates iron arrows
        ;Debug.MessageBox(itemDroppedMessage)
        MiscUtil.WriteToFile("in_game_events.txt", itemDroppedMessage)
    endIf
endEvent

; untested
Event OnActivate(ObjectReference akActionRef)
    ;Debug.MessageBox("OnActivate: " + akActionRef)
    MiscUtil.WriteToFile("in_game_events.txt", "OnActivate: " + akActionRef + ".\n")
EndEvent

; untested
Event OnClose(ObjectReference akActionRef)
    ;Debug.MessageBox("OnClose: " + akActionRef)
    MiscUtil.WriteToFile("in_game_events.txt", "OnClose: " + akActionRef + ".\n")
endEvent