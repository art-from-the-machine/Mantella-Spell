Scriptname MantellaMCM_MainSettings  Hidden 
{Mantella Main settings : hotkeys, timers, etc.}
; 
function Render(MantellaMCM mcm, MantellaRepository Repository) global
    ;This part of the MCM MainSettings script pretty much only serves to tell papyrus what button to display.
    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    LeftColumn(mcm, Repository)
    mcm.SetCursorPosition(1)
    RightColumn(mcm, Repository)
endfunction

function LeftColumn(MantellaMCM mcm, MantellaRepository Repository) global
    ;This part of the MCM MainSettings script pretty much only serves to tell papyrus what button to display using properties from the repository
    mcm.AddHeaderOption ("Button mapping")
    mcm.oid_keymapPromptHotkey=mcm.AddKeyMapOption ("Text prompt/Initiate conversation", repository.MantellaListenerTextHotkey)  
    mcm.oid_keymapCustomGameEventHotkey=mcm.AddKeyMapOption ("Enter text for custom game event", repository.MantellaCustomGameEventHotkey)  
endfunction

function RightColumn(MantellaMCM mcm, MantellaRepository Repository) global
    ;This part of the MCM MainSettings script pretty much only serves to tell papyrus what button to display using properties from the repository
    mcm.AddHeaderOption ("Settings")
    mcm.oid_responsetimeslider=mcm.AddSliderOption ("Text Response wait time",repository.MantellaEffectResponseTimer)
    mcm.oid_microphoneEnabledToggle=mcm.AddToggleOption("Microphone enabled", Repository.microphoneEnabled)
    mcm.oid_debugNPCselectMode=mcm.AddToggleOption("NPC Debug Select Mode", Repository.NPCdebugSelectModeEnabled)
endfunction

function SliderOptionOpen(MantellaMCM mcm, int optionID, MantellaRepository Repository) global
    ; SliderOptionOpen is used to choose what to display when the user clicks on the slider
    if optionID==mcm.oid_responsetimeslider
        mcm.SetSliderDialogStartValue(repository.MantellaEffectResponseTimer)
        mcm.SetSliderDialogDefaultValue(30)
        mcm.SetSliderDialogRange(0, 5000)
        mcm.SetSliderDialogInterval(1)
    endif
endfunction

function SliderOptionAccept(MantellaMCM mcm, int optionID, float value, MantellaRepository Repository) global
    ;SliderOptionAccept is used to update the Repository with the user input (that input will then be used by the Mantella effect script
    If  optionId == mcm.oid_responsetimeslider
        mcm.SetSliderOptionValue(optionId, value)
        Repository.MantellaEffectResponseTimer=value
    EndIf
endfunction


function KeyMapChange(MantellaMCM mcm,Int option, Int keyCode, String conflictControl, String conflictName, MantellaRepository Repository) global
    ;This script is used to check if a key is already used, if it's not it will update to a new value (stored in MantellaRepository) or it will prompt the user to warn him of the conflict. The actual keybind happens in MantellaRepository
    if option == mcm.oid_keymapPromptHotkey || mcm.oid_keymapCustomGameEventHotkey
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
            if option ==  mcm.oid_keymapPromptHotkey 
                repository.BindPromptHotkey(keyCode)
            ElseIf option ==  mcm.oid_keymapCustomGameEventHotkey
                repository.BindCustomGameEventHotkey(keyCode)
            endif
        endIf
    endIf
endfunction

function OptionUpdate(MantellaMCM mcm, int optionID, MantellaRepository Repository) global
    ;checks option per option what the toggle is and the updates the variable/function repository MantellaRepository so the MantellaEffect and Repository Hotkey function can access it
    if optionID==mcm.oid_microphoneEnabledToggle
        Repository.microphoneEnabled=!Repository.microphoneEnabled
        mcm.SetToggleOptionValue(mcm.oid_microphoneEnabledToggle, Repository.microphoneEnabled)
        MiscUtil.WriteToFile("_mantella_microphone_enabled.txt", Repository.microphoneEnabled,  append=false)
        debug.MessageBox("Please restart Mantella and start a new conversation for this option to take effect")
    ElseIf optionID==mcm.oid_debugNPCselectMode
        Repository.NPCdebugSelectModeEnabled=!Repository.NPCdebugSelectModeEnabled
        mcm.SetToggleOptionValue( mcm.oid_debugNPCselectMode, Repository.NPCdebugSelectModeEnabled)
    endif
endfunction