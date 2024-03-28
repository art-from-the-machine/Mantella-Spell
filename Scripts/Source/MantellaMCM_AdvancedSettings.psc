Scriptname MantellaMCM_AdvancedSettings Hidden

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
	mcm.AddHeaderOption("HTTP")
	mcm.oid_httpPort = mcm.AddInputOption("Port", Repository.HttpPort)
endfunction

function OptionInputUpdate(MantellaMCM mcm, int optionID, string inputText, MantellaRepository Repository) global
	If optionID == mcm.oid_httpPort
		int convertedInput = inputText as int
		if(convertedInput > 0 && convertedInput < 65535)
			Repository.HttpPort = convertedInput
			mcm.SetInputOptionValue(optionID, inputText)
		endIf
	endIf
endfunction

function OptionUpdate(MantellaMCM mcm, int optionID, MantellaRepository Repository) global
	if optionID == mcm.oid_debugNPCselectMode
		Repository.NPCdebugSelectModeEnabled =! Repository.NPCdebugSelectModeEnabled
		mcm.SetToggleOptionValue(mcm.oid_debugNPCselectMode, Repository.NPCdebugSelectModeEnabled)
	endIf
endfunction 
