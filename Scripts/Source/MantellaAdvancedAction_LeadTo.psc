Scriptname MantellaAdvancedAction_LeadTo extends Quest Hidden

MantellaInterface Property EventInterface Auto
MantellaConstants Property mConsts Auto
MantellaLocationUtils Property LocationUtils Auto
Faction Property MantellaFunctionSourceFaction Auto
ReferenceAlias Property LeadToLocationAlias Auto
ReferenceAlias Property LeadToSourceAlias Auto
ReferenceAlias Property LeadToTargetAlias Auto
Actor Property PlayerRef Auto

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_LEADTO, "OnNpcLeadToAdvancedActionReceived")
EndEvent


event OnNpcLeadToAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)
    MantellaConversation conversation = conversationQuest as MantellaConversation
    
    ; Extract parameters
    string sourceName = SKSE_HTTP.getString(argumentsHandle, mConsts.ACTION_ARG_SOURCE)
    string targetName = SKSE_HTTP.getString(argumentsHandle, mConsts.ACTION_ARG_TARGET)
    string locationName = SKSE_HTTP.getString(argumentsHandle, "location")
    
    ; Get destination marker
    ObjectReference markerRef = LocationUtils.MapMarkerLocationToRef(locationName)
    if !markerRef
        Debug.Notification("Could not find " + locationName)
        EventInterface.AddMantellaEvent("Cannot travel to unknown location: " + locationName + ".")
        return
    endif

    ; Clear any previous pending travel state
    ClearSourceAlias()
    
    ; Set destination
    LeadToLocationAlias.ForceRefTo(markerRef)
    
    Actor sourceActor = conversation.GetActorByName(sourceName)
    Actor targetActor = conversation.GetActorByName(targetName)

    if sourceActor && targetActor
        LeadTo(sourceActor, targetActor, locationName)
    endif
endEvent


Function ClearSourceAlias()
    ; Clear source alias to reset travel state
    if LeadToSourceAlias
        Actor sourceActor = LeadToSourceAlias.GetActorReference()
        if sourceActor
            sourceActor.RemoveFromFaction(MantellaFunctionSourceFaction)
            sourceActor.EvaluatePackage()
        endIf
        LeadToSourceAlias.Clear()
    endIf
EndFunction


Function LeadTo(Actor leaderActor, Actor followerActor, string locationName)
    LeadToSourceAlias.ForceRefTo(leaderActor)
    LeadToTargetAlias.ForceRefTo(followerActor)
    
    ; Clear wait state for followers to prevent them from getting stranded
    if leaderActor.IsPlayerTeammate()
        if leaderActor.GetActorValue("WaitingForPlayer") == 1
            leaderActor.SetActorValue("WaitingForPlayer", 0)
            Debug.Notification(leaderActor.GetDisplayName() + " is no longer waiting.")
        endif
    endif
    
    ; Set faction rank to activate package
    leaderActor.SetFactionRank(MantellaFunctionSourceFaction, 5) ; Rank 5 = LeadTo package
    
    ; Force AI to re-evaluate packages
    leaderActor.EvaluatePackage()
    if followerActor != PlayerRef
        followerActor.EvaluatePackage()
    endif
    
    Debug.Notification(leaderActor.GetDisplayName() + " is leading " + followerActor.GetDisplayName() + " to " + locationName + ".")
EndFunction