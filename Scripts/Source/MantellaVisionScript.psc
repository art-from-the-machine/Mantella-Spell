Scriptname MantellaVisionScript Hidden

import SUP_SKSE

Function GenerateMantellaVision(MantellaRepository repository) global
    Repository.hasPendingVisionCheck=true
    if repository.currentSKversion != "1.4.15.0" ;this basically checks if this is SKyrim VR or not, there is no option for taking screenshots through Papyrus in Skyrim VR currently
        if repository.allowHideInterfaceDuringScreenshot ;hide the HUD for the screenshot if this iption is enabled
            Game.SetHudCartMode()
            utility.wait(0.05)
            SUP_SKSE.CaptureScreenshot("Mantella_Vision", 0) ;screenshots are automatically saved in the root game directory
            Game.SetHudCartMode(false)
        else
            SUP_SKSE.CaptureScreenshot("Mantella_Vision", 0) ;screenshots are automatically saved in the root game directory
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