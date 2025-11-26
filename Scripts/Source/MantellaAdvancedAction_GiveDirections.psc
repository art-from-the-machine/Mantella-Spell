Scriptname MantellaAdvancedAction_GiveDirections extends Quest Hidden 

MantellaInterface Property EventInterface Auto
MantellaConstants Property mConsts Auto
MantellaLocationUtils Property LocationUtils Auto
Actor Property PlayerRef Auto

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_GIVEDIRECTIONS, "OnNpcGiveDirectionsAdvancedActionReceived")
EndEvent


event OnNpcGiveDirectionsAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)
    Debug.Notification("Thinking of directions...")

    string locationName = SKSE_HTTP.getString(argumentsHandle, "location")
    ObjectReference markerRef = LocationUtils.MapMarkerLocationToRef(locationName)

    if markerRef == None
        Debug.Notification("Marker ref not found for " + locationName)
        EventInterface.AddMantellaEvent("Cannot find location: " + locationName + ".")
    else
        ObjectReference fromRef = LocationUtils.GetCurrentLocationRef()
        
        if fromRef != None
            float distance = fromRef.GetDistance(markerRef)
            if distance == 0.0
                EventInterface.AddMantellaEvent(locationName + " is right here.")
            else
                ; Calculate compass direction from reference point to target
                float deltaX = markerRef.GetPositionX() - fromRef.GetPositionX()
                float deltaY = markerRef.GetPositionY() - fromRef.GetPositionY()

                float compassBearing = CalculateAngle(deltaX, deltaY)
                string direction = GetCompassDirection(compassBearing)
                string distanceText = FormatDistance(distance)
                
                string directions = locationName + " is " + distanceText + " " + direction + "."
                EventInterface.AddMantellaEvent(directions)
            endIf
        else
            EventInterface.AddMantellaEvent("Cannot determine directions to " + locationName + " from here.")
        endIf
    endIf
    
    ; Signal that the action has completed and events have been added
    EventInterface.MarkActionResponseCompleted(mConsts.ACTION_NPC_GIVEDIRECTIONS)
endEvent


float Function CalculateAngle(float deltaX, float deltaY)
    ; Calculate angle in degrees from deltaX and deltaY
    ; Returns 0-360 degrees where 0 = North, 90 = East, 180 = South, 270 = West
    
    ; Handle special cases to avoid division by zero
    if deltaX == 0.0 && deltaY == 0.0
        return 0.0
    elseIf deltaY == 0.0
        if deltaX > 0.0
            return 90.0 ; East
        else
            return 270.0 ; West
        endif
    elseIf deltaX == 0.0
        if deltaY > 0.0
            return 0.0 ; North
        else
            return 180.0 ; South
        endif
    endif
    
    float absX = Math.abs(deltaX)
    float absY = Math.abs(deltaY)
    float angle = Math.atan(absX / absY)
    
    float bearing
    if deltaY > 0.0 ; North half
        if deltaX > 0.0 ; Northeast
            bearing = angle
        else ; Northwest
            bearing = 360.0 - angle
        endif
    else ; South half
        if deltaX > 0.0 ; Southeast
            bearing = 180.0 - angle
        else ; Southwest
            bearing = 180.0 + angle
        endif
    endif
    
    if bearing < 0.0
        bearing += 360.0
    elseif bearing >= 360.0
        bearing -= 360.0
    endif
    
    return bearing
EndFunction


string Function GetCompassDirection(float bearing)
    ; 16-direction compass with 22.5 degree segments
    if bearing >= 348.75 || bearing < 11.25
        return "north"
    elseif bearing < 33.75
        return "north by northeast"
    elseif bearing < 56.25
        return "northeast"
    elseif bearing < 78.75
        return "east by northeast"
    elseif bearing < 101.25
        return "east"
    elseif bearing < 123.75
        return "east by southeast"
    elseif bearing < 146.25
        return "southeast"
    elseif bearing < 168.75
        return "south by southeast"
    elseif bearing < 191.25
        return "south"
    elseif bearing < 213.75
        return "south by southwest"
    elseif bearing < 236.25
        return "southwest"
    elseif bearing < 258.75
        return "west by southwest"
    elseif bearing < 281.25
        return "west"
    elseif bearing < 303.75
        return "west by northwest"
    elseif bearing < 326.25
        return "northwest"
    else
        return "north by northwest"
    endif
EndFunction


string Function FormatDistance(float gameUnits)
    ; Convert game units to kilometers
    float meterUnits = 71.0210
    float meters = gameUnits / meterUnits
    float kilometers = meters / 1000.0

    ; https://en.m.uesp.net/wiki/Skyrim%3ATransport
    ; Walk speed = 80 units / sec
    ; Walk speed / meterUnits = 80 / 71.0210 = 1.1264 m/s
    ; Actual time to walk 1 km = 1000 / 1.1264 / 3600 = 0.2466 hrs
    ; Skyrim time passes 20x faster than real time by default (ignoring mods that change time scale)
    ; Skyrim time to walk 1 km = 0.2466 * 20 = 4.932 hrs
    float kmWalkTime = 4.932
    float walkTime = kilometers * kmWalkTime

    ; Example walk times (straight lines) from Riverwood in hours for frame of reference:
    ; Whiterun = 2.61
    ; Falkreath = 4.64
    ; Morthal = 8.86
    ; Windhelm = 9.67
    ; Dawnstar = 10.54
    ; Riften = 11.14
    ; Winterhold = 11.93
    ; Solitude = 12.02
    
    if walkTime < 0.1
        return "just a short distance"
    elseif walkTime < 0.5
        return "a short walk"
    elseif walkTime < 1.5
        return "about an hour's walk"
    elseif walkTime < 2.5
        return "a couple of hours' walk"
    elseif walkTime < 4.0
        return "about half a day's walk"
    elseif walkTime < 5.0
        return "almost a day's walk"
    elseif walkTime < 6.0
        return "about a day's walk"
    ; Gradually dramatise longer distances
    elseif walkTime < 10.0
        return "about two days by foot, or almost a day on horseback"
    elseif walkTime < 14.0
        return "about three days by foot, or a little over a day on horseback"
    elseif walkTime < 17.0
        return "about four days by foot, or two days on horseback"
    elseif walkTime < 27.0
        return "almost a week by foot, less on horseback"
    else
        return "a very long journey"
    endIf
EndFunction