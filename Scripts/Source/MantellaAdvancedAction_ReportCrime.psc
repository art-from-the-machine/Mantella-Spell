Scriptname MantellaAdvancedAction_ReportCrime extends Quest Hidden 

Actor Property PlayerRef Auto
MantellaConstants property mConsts Auto
MantellaInterface property EventInterface Auto

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_REPORTCRIME, "OnNpcReportCrimeAdvancedActionReceived")
EndEvent

event OnNpcReportCrimeAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)
    MantellaConversation conversation = conversationQuest as MantellaConversation
    
    int crimeGold = SKSE_HTTP.getInt(argumentsHandle, "crime_gold")

    Actor guardActor = conversation.GetFirstGuardActor()
    
    ; If no guard in conversation, try to find and add one nearby
    if !guardActor
        guardActor = FindAndAddNearbyGuard(conversation)
    endIf
    
    if guardActor
        Faction crimeFaction = guardActor.GetCrimeFaction()
        crimeFaction.ModCrimeGold(crimeGold, false)

        Debug.Notification(crimeGold + " bounty added to " + crimeFaction.GetName())
        EventInterface.AddMantellaEvent("Crime reported against the player.")
    Else
        Debug.Notification("Crime report failed: No guard nearby")
        EventInterface.AddMantellaEvent("Cannot report crime without a guard nearby. Please inform the player you will report them later.")
    endIf

    EventInterface.MarkActionResponseCompleted(mConsts.ACTION_NPC_REPORTCRIME)
endEvent

Actor Function FindAndAddNearbyGuard(MantellaConversation conversation)
    Actor[] nearbyActors = conversation.GetCachedNearbyActors()
    
    if !nearbyActors || nearbyActors.Length == 0
        return None
    endIf
    
    int i = 0
    While i < nearbyActors.Length
        Actor nearbyActor = nearbyActors[i]
        if nearbyActor && nearbyActor.IsGuard()
            ; Create a single-element array of actors to add the guard to the conversation
            Actor[] guardToAdd = new Actor[1]
            guardToAdd[0] = nearbyActor
            Debug.Notification("Adding " + nearbyActor.GetDisplayName() + " to conversation...")
            conversation.AddActorsToConversation(guardToAdd)
            return nearbyActor
        endIf
        i += 1
    EndWhile
    
    return None
EndFunction