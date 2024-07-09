Scriptname MantellaMCM_VisionSettings  Hidden 

function Render(MantellaMCM mcm, MantellaRepository Repository) global
    ;This part of the MCM MainSettings script pretty much only serves to tell papyrus what button to display.
    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    LeftColumn(mcm, Repository)
    mcm.SetCursorPosition(1)
    RightColumn(mcm, Repository)
endfunction

function LeftColumn(MantellaMCM mcm, MantellaRepository Repository) global
    if repository.currentSKversion != "1.4.15.0" ;this basically checks if this is Skyrim VR or not, there is no function for taking screenshots through Papyrus in Skyrim VR currently so this reshuffles options
        mcm.AddHeaderOption("Enable automatic vision analysis")
        mcm.oid_automaticVisionAnalysis = mcm.AddToggleOption("Enabled", repository.allowVision)  
        mcm.AddHeaderOption("Vision hotkeys and screenshot options")
        mcm.oid_keymapVisionHotkey = mcm.AddKeyMapOption("Mantella Screenshot Hotkey", repository.MantellaVisionHotkey)
        mcm.oid_hideInterfaceDuringScreenshot = mcm.AddToggleOption("Hide interface during screenshots", repository.allowHideInterfaceDuringScreenshot) 
    else
        mcm.AddHeaderOption("Enable Steam screenshot analysis")
        mcm.oid_SteamVisionAnalysis = mcm.AddToggleOption("Enabled", repository.allowVision)
    endif
endfunction

function RightColumn(MantellaMCM mcm, MantellaRepository Repository) global
    mcm.AddHeaderOption("Set resolution and resize value")
    generateResolutionMenuList(mcm)
    mcm.oid_visionResolution = mcm.AddMenuOption("Resolution", mcm.resolutionMenuList[repository.visionResolutionIndex])
    mcm.oid_resize = mcm.AddSliderOption("Set resize value", repository.visionResize)
endfunction

function OptionUpdate(MantellaMCM mcm, int optionID, MantellaRepository Repository) global
    ;checks option per option what the toggle is and the updates the variable/function repository MantellaRepository so the MantellaEffect and Repository variables can access it
    if optionID == mcm.oid_automaticVisionAnalysis
        Repository.allowVision =! Repository.allowVision
        mcm.SetToggleOptionValue(mcm.oid_automaticVisionAnalysis, Repository.allowVision)
    elseif optionID == mcm.oid_SteamVisionAnalysis
        Repository.allowVision =! Repository.allowVision
        mcm.SetToggleOptionValue(mcm.oid_SteamVisionAnalysis, Repository.allowVision)
    elseif optionID == mcm.oid_hideInterfaceDuringScreenshot
        Repository.allowHideInterfaceDuringScreenshot =! Repository.allowHideInterfaceDuringScreenshot
        mcm.SetToggleOptionValue(mcm.oid_hideInterfaceDuringScreenshot, Repository.allowHideInterfaceDuringScreenshot)
    endif
endfunction

function generateResolutionMenuList(MantellaMCM mcm) global
    ;called by the right column display to generate the menu options
    mcm.resolutionMenuList = new string[3]
	mcm.resolutionMenuList[0] = "auto"
	mcm.resolutionMenuList[1] = "high"
	mcm.resolutionMenuList[2] = "low"
    mcm.resolutionMenuDefaultIndex = 1
endfunction

function updateRepositoryResolutionValues (MantellaMCM mcm, int indexID, MantellaRepository Repository) global
    ;updating both the index value for the array for the next time the vision menu loads and the resolution chosen
    repository.visionResolutionIndex = indexID
    repository.visionResolution = mcm.resolutionMenuList[indexID]
endfunction

function OptionInputMenuOpen(MantellaMCM mcm, int optionID, string[] menuList, int DefaultMenuIndex, MantellaRepository Repository) global
    if (optionID == mcm.oid_visionResolution)
        mcm.SetMenuDialogOptions(menuList)
        mcm.SetMenuDialogStartIndex(repository.visionResolutionIndex)
        mcm.SetMenuDialogDefaultIndex(DefaultMenuIndex)
    endIf
endfunction

function OptionInputMenuAccept(MantellaMCM mcm, int optionID, int indexID, MantellaRepository Repository) global
    ;updates repository according to the option chosen
    if (optionID == mcm.oid_visionResolution)
        updateRepositoryResolutionValues(mcm, indexID, repository)
        mcm.SetMenuOptionValue(mcm.oid_visionResolution, mcm.resolutionMenuList[indexID])
    endIf
endfunction

function KeyMapChange(MantellaMCM mcm,Int option, Int keyCode, String conflictControl, String conflictName, MantellaRepository Repository) global
    ;This script is used to check if a key is already used, if it's not it will update to a new value (stored in MantellaRepository) or it will prompt the user to warn him of the conflict. The actual keybind happens in MantellaRepository
    bool isOptionHotkey = option == mcm.oid_keymapVisionHotkey
    if (isOptionHotkey)
        Bool continue = true
        ;below checks if there's already a bound key
        if conflictControl != ""
            String ConflitMessage
            if conflictName != ""
                ConflitMessage = "Key already mapped to:\n'" + conflictControl + "'\n(" + conflictName + ")\n\nAre you sure you want to continue?"
            else
                ConflitMessage = "Key already mapped to:\n'" + conflictControl + "'\n\nAre you sure you want to continue?"
            endIf
            continue = mcm.ShowMessage(ConflitMessage, true, "$Yes", "$No")
        endIf
        if continue
            mcm.SetKeymapOptionValue(option, keyCode)
            ;selector to update the correct hotkey according to oid values
            if option == mcm.oid_keymapVisionHotkey
                repository.BindVisionHotkey(keyCode)
            endif
        endIf
    endIf
endfunction

function SliderOptionOpen(MantellaMCM mcm, int optionID, MantellaRepository Repository) global
    ; SliderOptionOpen is used to choose what to display when the user clicks on the slider
    if optionID==mcm.oid_resize
        mcm.SetSliderDialogStartValue(repository.visionResize)
        mcm.SetSliderDialogDefaultValue(1024)
        mcm.SetSliderDialogRange(0, 5000)
        mcm.SetSliderDialogInterval(1)
    endif
endfunction

function SliderOptionAccept(MantellaMCM mcm, int optionID, float value, MantellaRepository Repository) global
    ;SliderOptionAccept is used to update the Repository with the user input (that input will then be used by the Mantella effect script
    If  optionId == mcm.oid_resize
        mcm.SetSliderOptionValue(optionId, value)
        Repository.visionResize=value as int
    EndIf
endfunction