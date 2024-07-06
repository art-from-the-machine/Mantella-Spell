Scriptname MantellaVisionScript Hidden

import SUP_SKSE

Function GenerateMantellaVision(MantellaRepository repository) global
    Repository.hasPendingVisionCheck=true
    SUP_SKSE.CaptureScreenshot("Mantella_Vision", 0)
EndFunction

bool Function checkAndUpdateVisionPipeline(MantellaRepository repository) global
    ;automatically triggers to false to allow Camera and Spell to send the vision value only once per exchange.
    if repository.allowVision || repository.hasPendingVisionCheck
        repository.hasPendingVisionCheck=false
        return true
    else
        return false
    endif
EndFunction