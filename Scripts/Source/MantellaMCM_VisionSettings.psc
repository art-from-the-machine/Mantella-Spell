Scriptname MantellaMCM_VisionSettings  Hidden 
Import SUP_SKSE

function Render(MantellaMCM mcm, MantellaRepository Repository) global
    ;This part of the MCM MainSettings script pretty much only serves to tell papyrus what button to display.
    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    LeftColumn(mcm, Repository)
    mcm.SetCursorPosition(1)
    RightColumn(mcm, Repository)
endfunction

function LeftColumn(MantellaMCM mcm, MantellaRepository Repository) global
    ;if repository.currentSKversion == "1.6.640.0" || repository.currentSKversion == "1.5.97.0" || repository.currentSKversion == "1.6.659.0" ;Covers the SUP SKSE SUPPORTED VERSION
    
    int oid_automaticVisionAnalysis_flag = mcm.OPTION_FLAG_DISABLED
    int oid_SteamVisionAnalysis_flag = mcm.OPTION_FLAG_DISABLED
    int oid_steamScreenshotDelay_flag = mcm.OPTION_FLAG_DISABLED
    int oid_keymapVisionHotkey_flag = mcm.OPTION_FLAG_DISABLED
    int oid_hideInterfaceDuringScreenshot_flag = mcm.OPTION_FLAG_DISABLED
    int oid_allowVisionHints_flag = mcm.OPTION_FLAG_DISABLED
    int oid_VisionHintsHotkey_flag = mcm.OPTION_FLAG_DISABLED
    int oid_forceSkyrimVersion_flag = mcm.OPTION_FLAG_DISABLED
    int oid_allowVisionDebugMode_flag = mcm.OPTION_FLAG_DISABLED
    if repository.allowVisionDebugMode 
        oid_automaticVisionAnalysis_flag = mcm.OPTION_FLAG_NONE
        oid_SteamVisionAnalysis_flag = mcm.OPTION_FLAG_NONE
        oid_steamScreenshotDelay_flag = mcm.OPTION_FLAG_NONE
        oid_keymapVisionHotkey_flag = mcm.OPTION_FLAG_NONE
        oid_hideInterfaceDuringScreenshot_flag = mcm.OPTION_FLAG_NONE
        oid_allowVisionHints_flag = mcm.OPTION_FLAG_NONE
        oid_VisionHintsHotkey_flag = mcm.OPTION_FLAG_NONE
        oid_forceSkyrimVersion_flag = mcm.OPTION_FLAG_NONE
        oid_allowVisionDebugMode_flag = mcm.OPTION_FLAG_NONE
    elseif repository.currentSKversion == "1.4.15.0"
        oid_automaticVisionAnalysis_flag = mcm.OPTION_FLAG_DISABLED
        oid_SteamVisionAnalysis_flag = mcm.OPTION_FLAG_NONE
        oid_steamScreenshotDelay_flag = mcm.OPTION_FLAG_NONE
        oid_keymapVisionHotkey_flag = mcm.OPTION_FLAG_DISABLED
        oid_hideInterfaceDuringScreenshot_flag = mcm.OPTION_FLAG_DISABLED
        oid_allowVisionHints_flag = mcm.OPTION_FLAG_NONE
        oid_VisionHintsHotkey_flag = mcm.OPTION_FLAG_NONE
        oid_forceSkyrimVersion_flag = mcm.OPTION_FLAG_DISABLED
        oid_allowVisionDebugMode_flag = mcm.OPTION_FLAG_NONE
    elseif SUP_SKSE.GetSUPSKSEVersion()
        oid_automaticVisionAnalysis_flag = mcm.OPTION_FLAG_NONE
        oid_SteamVisionAnalysis_flag = mcm.OPTION_FLAG_DISABLED
        oid_steamScreenshotDelay_flag = mcm.OPTION_FLAG_DISABLED
        oid_keymapVisionHotkey_flag = mcm.OPTION_FLAG_NONE
        oid_hideInterfaceDuringScreenshot_flag = mcm.OPTION_FLAG_NONE
        oid_allowVisionHints_flag = mcm.OPTION_FLAG_NONE
        oid_VisionHintsHotkey_flag = mcm.OPTION_FLAG_DISABLED
        oid_forceSkyrimVersion_flag = mcm.OPTION_FLAG_DISABLED
        oid_allowVisionDebugMode_flag = mcm.OPTION_FLAG_NONE
    Else
        oid_automaticVisionAnalysis_flag = mcm.OPTION_FLAG_DISABLED
        oid_SteamVisionAnalysis_flag = mcm.OPTION_FLAG_NONE
        oid_steamScreenshotDelay_flag = mcm.OPTION_FLAG_NONE
        oid_keymapVisionHotkey_flag = mcm.OPTION_FLAG_DISABLED
        oid_hideInterfaceDuringScreenshot_flag = mcm.OPTION_FLAG_DISABLED
        oid_allowVisionHints_flag = mcm.OPTION_FLAG_NONE
        oid_VisionHintsHotkey_flag = mcm.OPTION_FLAG_NONE
        oid_forceSkyrimVersion_flag = mcm.OPTION_FLAG_DISABLED
        oid_allowVisionDebugMode_flag = mcm.OPTION_FLAG_NONE
    endif
    
    if repository.allowVisionDebugMode 
        mcm.AddHeaderOption("Debug mode enabled")
        mcm.AddHeaderOption("Some options might not work")
    endif
    if SUP_SKSE.GetSUPSKSEVersion()
        mcm.AddHeaderOption("Enable automatic vision analysis")
    else
        mcm.AddHeaderOption("Enable vision analysis")
    endif
    mcm.oid_automaticVisionAnalysis = mcm.AddToggleOption("Enable SUP_SKSE vision", repository.allowVision, oid_automaticVisionAnalysis_flag) 
    mcm.oid_SteamVisionAnalysis = mcm.AddToggleOption("Enable Steam vision", repository.allowVision, oid_SteamVisionAnalysis_flag)
    mcm.oid_steamScreenshotDelay = mcm.AddSliderOption("Select steam screenshot delay", repository.steamScreenshotDelay, "{0} seconds", oid_steamScreenshotDelay_flag)
    mcm.AddHeaderOption("Vision hotkeys and screenshot options")
    mcm.oid_keymapVisionHotkey = mcm.AddKeyMapOption("Mantella Screenshot Hotkey", repository.MantellaVisionHotkey, oid_keymapVisionHotkey_flag )
    mcm.oid_hideInterfaceDuringScreenshot = mcm.AddToggleOption("Hide interface during screenshots", repository.allowHideInterfaceDuringScreenshot, oid_hideInterfaceDuringScreenshot_flag) 
    mcm.oid_allowVisionHints = mcm.AddToggleOption("Send vision hints to the LLM", repository.allowVisionHints, oid_allowVisionHints_flag) 
    mcm.oid_VisionHintsHotkey = mcm.AddKeyMapOption("Mantella Hints Hotkey", repository.MantellaVisionHintsHotkey, oid_VisionHintsHotkey_flag)
    mcm.oid_forceSkyrimVersion = mcm.AddInputOption("Emulate a specific Skyrim version", Repository.currentSKversion, oid_forceSkyrimVersion_flag)
    mcm.AddHeaderOption("Advanced options")
    mcm.oid_allowVisionDebugMode = mcm.AddToggleOption("Allows Vision Debug Mode", repository.allowVisionDebugMode, oid_allowVisionDebugMode_flag) 
    
endfunction

function RightColumn(MantellaMCM mcm, MantellaRepository Repository) global
    mcm.AddHeaderOption("Set resolution and resize value")
    generateResolutionMenuList(mcm)
    mcm.oid_visionResolution = mcm.AddMenuOption("Resolution", mcm.resolutionMenuList[repository.visionResolutionIndex])
    mcm.oid_resize = mcm.AddSliderOption("Set resize value", repository.visionResize, "{0} pixels width")
endfunction

function OptionUpdate(MantellaMCM mcm, int optionID, MantellaRepository Repository) global
    ;checks option per option what the toggle is and the updates the variable/function repository MantellaRepository so the MantellaEffect and Repository variables can access it
    if optionID == mcm.oid_automaticVisionAnalysis
        Repository.allowVision =! Repository.allowVision
        mcm.SetToggleOptionValue(mcm.oid_automaticVisionAnalysis, Repository.allowVision)
    elseif optionID == mcm.oid_SteamVisionAnalysis
        Repository.allowVision =! Repository.allowVision
        Repository.isUsingSteamScreenshot = Repository.allowVision
        mcm.SetToggleOptionValue(mcm.oid_SteamVisionAnalysis, Repository.allowVision)
    elseif optionID == mcm.oid_hideInterfaceDuringScreenshot
        Repository.allowHideInterfaceDuringScreenshot =! Repository.allowHideInterfaceDuringScreenshot
        mcm.SetToggleOptionValue(mcm.oid_hideInterfaceDuringScreenshot, Repository.allowHideInterfaceDuringScreenshot)
    elseif optionID == mcm.oid_allowVisionHints
        Repository.allowVisionHints =! Repository.allowVisionHints
        mcm.SetToggleOptionValue(mcm.oid_allowVisionHints, Repository.allowVisionHints)
    elseif optionID == mcm.oid_allowVisionDebugMode
        Repository.allowVisionDebugMode =! Repository.allowVisionDebugMode
        mcm.SetToggleOptionValue(mcm.oid_allowVisionDebugMode, Repository.allowVisionDebugMode)
        mcm.forcepagereset()
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
        mcm.forcepagereset()
    endIf
endfunction

function OptionInputUpdate(MantellaMCM mcm, int optionID, string inputText, MantellaRepository Repository) global
	If optionID == mcm.oid_forceSkyrimVersion
		string convertedInput = inputText as string
        Repository.currentSKversion = convertedInput
        mcm.SetInputOptionValue(optionID, inputText)
        repository.allowVisionDebugMode = false
        Render(mcm,Repository)
	endIf
endfunction

function KeyMapChange(MantellaMCM mcm,Int option, Int keyCode, String conflictControl, String conflictName, MantellaRepository Repository) global
    ;This script is used to check if a key is already used, if it's not it will update to a new value (stored in MantellaRepository) or it will prompt the user to warn him of the conflict. The actual keybind happens in MantellaRepository
    bool isOptionHotkey = option == mcm.oid_keymapVisionHotkey || option == mcm.oid_VisionHintsHotkey 
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
            elseif option == mcm.oid_VisionHintsHotkey
                repository.BindVisionHintsHotkey(keyCode)
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
    elseif optionID==mcm.oid_steamScreenshotDelay
            mcm.SetSliderDialogStartValue(repository.steamScreenshotDelay)
            mcm.SetSliderDialogDefaultValue(120)
            mcm.SetSliderDialogRange(0, 480)
            mcm.SetSliderDialogInterval(1)
    endif
endfunction

function SliderOptionAccept(MantellaMCM mcm, int optionID, float value, MantellaRepository Repository) global
    ;SliderOptionAccept is used to update the Repository with the user input (that input will then be used by the Mantella effect script
    If  optionId == mcm.oid_resize
        mcm.SetSliderOptionValue(optionId, value)
        Repository.visionResize=value as int
    elseif  optionId == mcm.oid_steamScreenshotDelay
            mcm.SetSliderOptionValue(optionId, value)
            Repository.steamScreenshotDelay=value as int
    EndIf
endfunction