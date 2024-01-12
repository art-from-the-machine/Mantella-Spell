Scriptname MantellaMCM_AdvancedSettings  Hidden 

function Render(MantellaMCM mcm, MantellaRepository Repository) global
    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    LeftColumn(mcm, Repository)
    mcm.SetCursorPosition(1)
    RightColumn(mcm, Repository)
endfunction

function LeftColumn(MantellaMCM mcm, MantellaRepository Repository) global
	mcm.AddHeaderOption("Debug")
	mcm.oid_debugNPCselectMode = mcm.AddToggleOption("NPC Debug Select Mode", Repository.NPCdebugSelectModeEnabled)
endfunction

function RightColumn(MantellaMCM mcm, MantellaRepository Repository) global
endfunction

function OptionUpdate(MantellaMCM mcm, int optionID, MantellaRepository Repository) global
	if optionID == mcm.oid_debugNPCselectMode
		Repository.NPCdebugSelectModeEnabled =! Repository.NPCdebugSelectModeEnabled
		mcm.SetToggleOptionValue(mcm.oid_debugNPCselectMode, Repository.NPCdebugSelectModeEnabled)
	endIf
endfunction 
