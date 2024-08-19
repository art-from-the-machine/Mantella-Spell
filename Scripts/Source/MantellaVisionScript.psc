Scriptname MantellaVisionScript Hidden

Import SUP_SKSE
Import MiscUtil

Function GenerateMantellaVision(MantellaRepository repository) global
    Repository.hasPendingVisionCheck=true
    if !repository.isUsingSteamScreenshot;this basically checks if screenshots are taken through Steam or not
        if repository.allowHideInterfaceDuringScreenshot ;hide the HUD for the screenshot if this iption is enabled
            Game.SetHudCartMode()
            utility.wait(0.05)
            SUP_SKSE.CaptureScreenshot("Mantella_Vision", 0) ;screenshots are automatically saved in the root game directory
            Game.SetHudCartMode(false)
        else
            SUP_SKSE.CaptureScreenshot("Mantella_Vision", 0) ;screenshots are automatically saved in the root game directory
        endif
        if Repository.allowVisionHints
            ScanCellForActors(repository, true, true)
        endif
    endif
EndFunction

bool Function checkAndUpdateVisionPipeline(MantellaRepository repository) global
    ;automatically triggers to false to allow the hotkey to send the vision value only once per exchange.
    if repository.allowVision || repository.hasPendingVisionCheck
        repository.hasPendingVisionCheck=false
        return true
    else
        return false
    endif
EndFunction

Actor[] Function ScanCellForActors(MantellaRepository repository, bool filteredByPlayerLOS, bool updateProperties) global
    ;if filteredByPlayerLOS is turned on this only returns an array of actors visible to the player
    ;if updateProperties is turned on it will fill the properties of ActorsInCellArray & currentDistanceArray with the scanned actors names and distances
    ;if updateProperties is turned off it will return the values of the actors in array form
    resetVisionHintsArrays(repository)
    Actor playerRef = Game.GetPlayer()
    Actor[] ActorsInCell = MiscUtil.ScanCellNPCs(playerRef)
    if filteredByPlayerLOS 
        int i
        While i < ActorsInCell.Length
            Actor currentActor = ActorsInCell[i]
            float currentDistance = playerRef.GetDistance(currentActor)
            if playerRef.HasLOS (currentActor)
                 if currentActor.GetDisplayName()!="" && currentDistance<4500 && currentActor != PlayerRef && updateProperties
                    repository.ActorsInCellArray+="["+currentActor.GetDisplayName()+"],"
                    repository.VisionDistanceArray += "["+currentDistance+"]," 
                endif
            endif
            i += 1
        EndWhile
        debug.notification("ActorsInCellArray is "+repository.ActorsInCellArray)
    endif
    if !updateProperties
        return ActorsInCell
    endif
Endfunction

Function resetVisionHintsArrays(MantellaRepository repository) global
    repository.ActorsInCellArray=""
    repository.VisionDistanceArray = ""
Endfunction