Scriptname MantellaMCM_RadiantDialogue  Hidden 
function Render(MantellaMCM mcm, MantellaRepository Repository) global
    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    LeftColumn(mcm, Repository)
    mcm.SetCursorPosition(1)
    ;RightColumn(mcm, Repository)
endfunction


function LeftColumn(MantellaMCM mcm, MantellaRepository Repository) global
    mcm.AddHeaderOption ("Radiant Dialogue")
    mcm.oid_radiantenabled = mcm.AddToggleOption("Enable", repository.radiantEnabled)
    mcm.oid_radiantdistance = mcm.AddSliderOption("Trigger Distance",repository.radiantDistance)
    mcm.oid_radiantfrequency = mcm.AddSliderOption("Frequency",repository.radiantFrequency)
endfunction

;function RightColumn(MantellaMCM mcm, MantellaRepository Repository) global   
;endfunction


function OptionUpdate(MantellaMCM mcm, int optionID, MantellaRepository Repository) global
    ;checks option per option what the toggle is and the updates the var repository MantellaRepository
    if optionID==mcm.oid_radiantenabled
        repository.radiantEnabled = !mcm.repository.radiantEnabled
        mcm.SetToggleOptionValue(mcm.oid_radiantenabled, repository.radiantEnabled)
    endIf
endfunction

function SliderOptionOpen(MantellaMCM mcm, int optionID, MantellaRepository Repository) global
    ; SliderOptionOpen is used to choose what to display when the user clicks on the slider
    if optionID==mcm.oid_radiantdistance
        mcm.SetSliderDialogStartValue(repository.radiantDistance)
        mcm.SetSliderDialogDefaultValue(20)
        mcm.SetSliderDialogRange(1, 250)
        mcm.SetSliderDialogInterval(1)
    elseIf optionID==mcm.oid_radiantfrequency
        mcm.SetSliderDialogStartValue(repository.radiantFrequency)
        mcm.SetSliderDialogDefaultValue(10)
        mcm.SetSliderDialogRange(5, 300)
        mcm.SetSliderDialogInterval(1)
    endif
endfunction

function SliderOptionAccept(MantellaMCM mcm, int optionID, float value, MantellaRepository Repository) global
    ;SliderOptionAccept is used to update the Repository with the user input (that input will then be used by the Mantella effect script
    if optionId == mcm.oid_radiantdistance
        mcm.SetSliderOptionValue(optionId, value)
        Repository.radiantDistance=value
        debug.MessageBox("Please save and reload for this change to take effect")
    elseIf optionId == mcm.oid_radiantfrequency
        mcm.SetSliderOptionValue(optionId, value)
        Repository.radiantFrequency=value
        debug.MessageBox("Please save and reload for this change to take effect")
    endIf
endfunction