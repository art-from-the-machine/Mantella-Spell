Scriptname MantellaAdvancedAction_TravelTo extends Quest Hidden 

MantellaInterface Property EventInterface Auto
MantellaConstants Property mConsts Auto
MantellaLocationUtils Property LocationUtils Auto
Faction Property MantellaFunctionSourceFaction Auto
Package Property MantellaTravelToPackage Auto
ReferenceAlias Property TravelToLocationAlias Auto
GlobalVariable Property MantellaTravelExpireTime Auto
GlobalVariable Property GameDaysPassed Auto

; Pending travel state (set when action received, executed when conversation ends)
string pendingLocationName
int maxTravelers ; Limited by number of source aliases created in CK

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_TRAVELTO, "OnNpcTravelToAdvancedActionReceived")
    RegisterForModEvent(EventInterface.EVENT_CONVERSATION_ENDED, "OnConversationEndedReceived")
EndEvent


event OnNpcTravelToAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)
    MantellaConversation conversation = conversationQuest as MantellaConversation
    
    ; Extract parameters
    string[] sourceNames = SKSE_HTTP.getStringArray(argumentsHandle, mConsts.ACTION_ARG_SOURCE)
    string locationName = SKSE_HTTP.getString(argumentsHandle, "location")
    bool leaveNow = SKSE_HTTP.getBool(argumentsHandle, "leave_now")
    
    ; Get destination marker
    ObjectReference markerRef = LocationUtils.MapMarkerLocationToRef(locationName)
    if !markerRef
        Debug.Notification("Could not find " + locationName)
        EventInterface.AddMantellaEvent("Cannot travel to unknown location: " + locationName + ".")
        return
    endif

    ; Clear any previous pending travel state
    ClearSourceAliases()
    pendingLocationName = ""
    maxTravelers = 12
    
    ; Set destination
    TravelToLocationAlias.ForceRefTo(markerRef)

    ; Set travel time
    SetTravelExpireTime(markerRef, locationName)
    
    ; Store location name for use when conversation ends
    pendingLocationName = locationName
    
    ; Collect source actors for deferred travel
    int i = 0
    While i < sourceNames.Length && i < maxTravelers
        Actor sourceActor = conversation.GetActorByName(sourceNames[i])
        if sourceActor
            PrepareTravel(sourceActor, i, leaveNow)
        endif
        i += 1
    EndWhile

    if leaveNow
        ; Execute travel immediately
        ExecuteTravel()
    endif
endEvent


event OnConversationEndedReceived()
    ; Execute any pending travel when conversation ends
    ExecuteTravel()
endEvent


Function ClearSourceAliases()
    ; Clear all source aliases to reset travel state
    int i = 0
    While i < maxTravelers
        ReferenceAlias sourceAlias = self.GetNthAlias(i) as ReferenceAlias
        if sourceAlias
            Actor sourceActor = sourceAlias.GetActorReference()
            if sourceActor
                sourceActor.RemoveFromFaction(MantellaFunctionSourceFaction)
                sourceActor.EvaluatePackage()
            endIf
            sourceAlias.Clear()
        endIf
        i += 1
    EndWhile
EndFunction


Function PrepareTravel(Actor traveler, int aliasIndex, bool leaveNow)
    ; Assign to alias now (adds package to their stack, but it won't activate until faction rank is set)
    ReferenceAlias sourceAlias = self.GetNthAlias(aliasIndex) as ReferenceAlias
    sourceAlias.ForceRefTo(traveler)
    
    ; Notify that travel is planned
    if !leaveNow
        string notification = traveler.GetDisplayName() + " will travel to " + pendingLocationName + " after the conversation."
        Debug.Notification(notification)
        EventInterface.AddMantellaEvent(notification)
    endif
EndFunction


Function ExecuteTravel()
    ; Loop through source aliases and execute travel for any that are filled
    int i = 0
    While i < maxTravelers
        ReferenceAlias sourceAlias = self.GetNthAlias(i) as ReferenceAlias
        if sourceAlias
            Actor traveler = sourceAlias.GetActorReference()
            ; Skip if no traveler or already traveling (faction rank 2 means travel already activated)
            if traveler && traveler.GetFactionRank(MantellaFunctionSourceFaction) != 2
                ; Clear wait state for followers to prevent them from getting stranded
                if traveler.IsPlayerTeammate()
                    if traveler.GetActorValue("WaitingForPlayer") == 1
                        traveler.SetActorValue("WaitingForPlayer", 0)
                        Debug.Notification(traveler.GetDisplayName() + " is no longer waiting.")
                    endif
                endif
                
                ; Set faction rank to activate package condition
                traveler.SetFactionRank(MantellaFunctionSourceFaction, 2) ; Use rank 2 for travel
                
                ; Force AI to re-evaluate packages
                traveler.EvaluatePackage()
                
                Debug.Notification(traveler.GetDisplayName() + " will now travel to " + pendingLocationName + ".")
            endif
        endif
        i += 1
    EndWhile
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
    EventInterface.AddMantellaEvent(travelTimeNotification)

    float expireTime = GameDaysPassed.GetValue() + travelDaysWithBuffer ; Travel time with 50% buffer
    MantellaTravelExpireTime.SetValue(expireTime)
EndFunction