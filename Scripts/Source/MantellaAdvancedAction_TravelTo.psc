Scriptname MantellaAdvancedAction_TravelTo extends Quest Hidden 

MantellaInterface Property EventInterface Auto
MantellaConstants Property mConsts Auto
MantellaLocationUtils Property LocationUtils Auto
Faction Property MantellaFunctionSourceFaction Auto
Package Property MantellaTravelToPackage Auto
ReferenceAlias Property TravelToLocationAlias Auto
GlobalVariable Property MantellaTravelExpireTime Auto
GlobalVariable Property GameDaysPassed Auto

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_TRAVELTO, "OnNpcTravelToAdvancedActionReceived")
EndEvent


event OnNpcTravelToAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)
    MantellaConversation conversation = conversationQuest as MantellaConversation
    
    ; Extract parameters
    string[] sourceNames = SKSE_HTTP.getStringArray(argumentsHandle, mConsts.ACTION_ARG_SOURCE)
    string locationName = SKSE_HTTP.getString(argumentsHandle, "location")
    
    ; Get destination marker
    ObjectReference markerRef = LocationUtils.MapMarkerLocationToRef(locationName)
    if !markerRef
        Debug.Notification("Could not find " + locationName)
        EventInterface.AddMantellaEvent("Cannot travel to unknown location: " + locationName + ".")
        EventInterface.MarkActionResponseCompleted(mConsts.ACTION_NPC_TRAVELTO)
        return
    endif
    
    ; Set destination
    TravelToLocationAlias.ForceRefTo(markerRef)

    ; Set travel time
    SetTravelExpireTime(markerRef, locationName)
    
    ; Process each source actor
    int i = 0
    While i < sourceNames.Length && i < 1 ; Only 1 source alias for now
        Actor sourceActor = conversation.GetActorByName(sourceNames[i])
        if sourceActor
            StartTravel(sourceActor, locationName)
        endif
        i += 1
    EndWhile

    EventInterface.MarkActionResponseCompleted(mConsts.ACTION_NPC_TRAVELTO)
endEvent


Function StartTravel(Actor traveler, string locationName)
    ; Clear wait state for followers to prevent them getting stranded if they stop before reaching their destination
    if traveler.IsPlayerTeammate()
        if traveler.GetActorValue("WaitingForPlayer") == 1
            traveler.SetActorValue("WaitingForPlayer", 0)
            Debug.Notification(traveler.GetDisplayName() + " is no longer waiting.")
        endif
    endif
    
    ; Assign to alias (adds package to their stack)
    ReferenceAlias sourceAlias = self.GetNthAlias(0) as ReferenceAlias
    sourceAlias.ForceRefTo(traveler)
    
    ; Set faction rank to activate package condition
    traveler.SetFactionRank(MantellaFunctionSourceFaction, 2) ; Use rank 2 for travel
    
    ; Force AI to re-evaluate packages
    traveler.EvaluatePackage()
    
    string confirmationMessage = traveler.GetDisplayName() + " is traveling to " + locationName + "."
    Debug.Notification(confirmationMessage)
    EventInterface.AddMantellaEvent(confirmationMessage)
EndFunction


Function SetTravelExpireTime(ObjectReference markerRef, string locationName)
    ; Get estimated travel time
    float travelDays = LocationUtils.CalculateTravelDays(markerRef)
    ; Set minimum to 1 Skyrim hour (1/24 = 0.042 days)
    if travelDays < 0.042
        travelDays = 0.042
    endif

    float travelDaysWithBuffer = travelDays * 1.5
    int travelDaysWithBufferInt = travelDaysWithBuffer as int

    string travelTimeNotification
    if travelDaysWithBufferInt < 1
        travelTimeNotification = "Estimated travel time to " + locationName + ": Less than a day."
    else
        travelTimeNotification = "Estimated travel time to " + locationName + ": " + travelDaysWithBuffer as int + " days."
    endIf
    Debug.Notification(travelTimeNotification)
    EventInterface.AddMantellaEvent(travelTimeNotification)

    float expireTime = GameDaysPassed.GetValue() + travelDaysWithBuffer ; Travel time with 50% buffer
    MantellaTravelExpireTime.SetValue(expireTime)
EndFunction