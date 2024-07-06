Scriptname MantellaMCM_VisionSettings  Hidden 

function Render(MantellaMCM mcm, MantellaRepository Repository) global
    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    LeftColumn(mcm, Repository)
    mcm.SetCursorPosition(1)
    RightColumn(mcm, Repository)
endfunction

function LeftColumn(MantellaMCM mcm, MantellaRepository Repository) global
    mcm.AddHeaderOption("Enable automatic vision analsis")
    mcm.oid_automaticVisionAnalysis = mcm.AddToggleOption("Enabled", repository.allowVision)
endfunction

function RightColumn(MantellaMCM mcm, MantellaRepository Repository) global
    mcm.AddHeaderOption("Set resolution")
    generateResolutionMenuList(mcm)
    mcm.oid_visionResolution = mcm.AddMenuOption("Resolution", mcm.resolutionMenuList[repository.visionResolutionIndex])
endfunction

function OptionUpdate(MantellaMCM mcm, int optionID, MantellaRepository Repository) global
    ;checks option per option what the toggle is and the updates the variable/function repository MantellaRepository so the MantellaEffect and Repository Hotkey function can access it
    if optionID == mcm.oid_automaticVisionAnalysis
        Repository.allowVision =! Repository.allowVision
        mcm.SetToggleOptionValue(mcm.oid_automaticVisionAnalysis, Repository.allowVision)
    endif
endfunction

function generateResolutionMenuList(MantellaMCM mcm) global
    mcm.resolutionMenuList = new string[3]
	mcm.resolutionMenuList[0] = "auto"
	mcm.resolutionMenuList[1] = "high"
	mcm.resolutionMenuList[2] = "low"
    mcm.resolutionMenuDefaultIndex = 1
endfunction

function updateRepositoryResolutionValues (MantellaMCM mcm, int indexID, MantellaRepository Repository) global
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
    if (optionID == mcm.oid_visionResolution)
        updateRepositoryResolutionValues(mcm, indexID, repository)
        mcm.SetMenuOptionValue(mcm.oid_visionResolution, mcm.resolutionMenuList[indexID])
    endIf
endfunction