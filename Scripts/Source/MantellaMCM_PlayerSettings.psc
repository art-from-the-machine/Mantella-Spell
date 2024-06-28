Scriptname MantellaMCM_PlayerSettings  Hidden 
{This is the menu page for setting for player character settings.}
function Render(MantellaMCM mcm, MantellaRepository Repository) global
     ;This part of the MCM MainSettings script pretty much only serves to tell papyrus what button to display.
    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    LeftColumn(mcm, Repository)
    mcm.SetCursorPosition(1)
    RightColumn(mcm, Repository)
endfunction


function LeftColumn(MantellaMCM mcm, MantellaRepository Repository) global
    ;This part of the MCM MainSettings script pretty much only serves to tell papyrus what button to display using properties from the repository
    mcm.AddHeaderOption ("Player character setup")
    If (Repository.IsVR())
        mcm.AddTextOption("For VR, use Mantella Software config", true)
    else
        mcm.oid_playerCharacterDescription1 = mcm.AddTextOption("Set default PC description", Repository.playerCharacterDescription1)
        mcm.oid_playerCharacterDescription2 = mcm.AddTextOption("Set alternative PC description", Repository.playerCharacterDescription2)
        mcm.oid_playerCharacterUsePlayerDescription2 = mcm.AddToggleOption("Use alternative description", Repository.playerCharacterUsePlayerDescription2)
        mcm.oid_playerCharacterVoicePlayerInput = mcm.AddToggleOption("Voice player input", Repository.playerCharacterVoicePlayerInput)
        mcm.oid_playerCharacterVoiceModel = mcm.AddTextOption("Set PC voice model", Repository.playerCharacterVoiceModel)
    EndIf
    mcm.AddHeaderOption ("Event tracking options")
    mcm.oid_playerTrackingUsePCName=mcm.AddToggleOption("Use name of player character", repository.playerTrackingUsePCName)
endfunction

function RightColumn(MantellaMCM mcm, MantellaRepository Repository) global    
endfunction

string Function GetTextInput(string existingValue) global
    UIExtensions.SetMenuPropertyString("UITextEntryMenu","text", existingValue)
    UIExtensions.InitMenu("UITextEntryMenu")
    UIExtensions.OpenMenu("UITextEntryMenu")    
    return UIExtensions.GetMenuResultString("UITextEntryMenu")    
EndFunction

function OptionUpdate(MantellaMCM mcm, int optionID, MantellaRepository Repository) global
    ;checks option per option what the toggle is and the updates the var repository MantellaRepository so the ListenerScript can access it
    if optionID==mcm.oid_playerTrackingUsePCName
        repository.playerTrackingUsePCName=!mcm.repository.playerTrackingUsePCName
        mcm.SetToggleOptionValue(mcm.oid_playerTrackingUsePCName, repository.playerTrackingUsePCName)
    ElseIf (optionID == mcm.oid_playerCharacterUsePlayerDescription2) ;Player Character options
        repository.playerCharacterUsePlayerDescription2 =!mcm.repository.playerCharacterUsePlayerDescription2
        mcm.SetToggleOptionValue(optionID, repository.playerCharacterUsePlayerDescription2)    
    ElseIf (optionID == mcm.oid_playerCharacterVoicePlayerInput) ;Player Character options
        repository.playerCharacterVoicePlayerInput =!mcm.repository.playerCharacterVoicePlayerInput
        mcm.SetToggleOptionValue(optionID, repository.playerCharacterVoicePlayerInput)
    elseIf optionID == mcm.oid_playerCharacterDescription1
        Repository.playerCharacterDescription1 = GetTextInput(Repository.playerCharacterDescription1)
    ElseIf optionID == mcm.oid_playerCharacterDescription2
        Repository.playerCharacterDescription2 = GetTextInput(Repository.playerCharacterDescription2)
    ElseIf (optionID == mcm.oid_playerCharacterVoiceModel)
        Repository.playerCharacterVoiceModel = GetTextInput(Repository.playerCharacterVoiceModel)
    endIf
endfunction 

