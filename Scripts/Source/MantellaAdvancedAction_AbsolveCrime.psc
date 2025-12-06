Scriptname MantellaAdvancedAction_AbsolveCrime extends Quest Hidden 

Actor Property PlayerRef Auto
MantellaConstants property mConsts Auto
MantellaInterface property EventInterface Auto

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_ABSOLVECRIME, "OnNpcAbsolveCrimeAdvancedActionReceived")
EndEvent

event OnNpcAbsolveCrimeAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)
    MantellaConversation conversation = conversationQuest as MantellaConversation
    
    int crimeGold = SKSE_HTTP.getInt(argumentsHandle, "crime_gold")

    Actor guardActor = conversation.GetFirstGuardActor()
    if guardActor
        Faction crimeFaction = guardActor.GetCrimeFaction()
        crimeFaction.ModCrimeGold(-crimeGold, false)

        Debug.Notification(crimeGold + " bounty removed from " + crimeFaction.GetName())
        EventInterface.AddMantellaEvent("Crime absolved against the player.")
    Else
        Debug.Notification("Crime not absolved: No guard in conversation")
        EventInterface.AddMantellaEvent("Cannot absolve crime without a guard in the conversation. Please add a guard to the conversation.")
    endIf

    EventInterface.MarkActionResponseCompleted(mConsts.ACTION_NPC_ABSOLVECRIME)
endEvent