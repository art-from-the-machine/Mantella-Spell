Scriptname MantellaMCM_followingNPCSettings  Hidden 

{This is the settings page for target event tracking.}

function Render(MantellaMCM mcm, MantellaRepository Repository) global
    ;This part of the MCM MainSettings script pretty much only serves to tell papyrus what button to display.
    mcm.SetCursorFillMode(mcm.TOP_TO_BOTTOM)
    LeftColumn(mcm, Repository)
    mcm.SetCursorPosition(1)
    RightColumn(mcm, Repository)
endfunction

function LeftColumn(MantellaMCM mcm, MantellaRepository Repository) global
     ;This part of the MCM MainSettings script pretty much only serves to tell papyrus what button to display using properties from the repository
    ;generates left column
    mcm.AddHeaderOption ("Following NPC(s)")
	mcm.oid_AllowForNPCtoFollowToggle=mcm.AddToggleOption("Enable Mantella followers", Repository.AllowForNPCtoFollow)
	;if game.getplayer().isinfaction(Repository.giafac_AllowFollower)
	mcm.oid_followingNPCsitToggle=mcm.AddToggleOption("NPCs sit when player sits", Repository.followingNPCsit)
	mcm.oid_followingNPCsleepToggle=mcm.AddToggleOption("NPCs sleep when player sleeps", Repository.followingNPCsleep)
	;endif

endfunction

function RightColumn(MantellaMCM mcm, MantellaRepository Repository) global
    ;generates the toggle buttons on the right side
    mcm.AddHeaderOption ("General Behavior")
	mcm.oid_NPCDialogueToggle=mcm.AddToggleOption("Initiate conversation through dialogue", Repository.NPCDialogue)
	mcm.oid_NPCAngerToggle=mcm.AddToggleOption("NPCs Can get angry", Repository.NPCAnger)
	mcm.oid_NPCForgiveToggle=mcm.AddToggleOption("NPCs Can forgive", Repository.NPCForgive)
	;mcm.oid_NPCstopandTalkToggle=mcm.AddToggleOption("NPCs stops moving to talk", Repository.NPCstopandTalk)

endfunction

function OptionUpdate(MantellaMCM mcm, int optionID, MantellaRepository Repository) global
    ;checks option per option what the toggle is and the updates the var repository MantellaRepository so the targetListenerScript can access it

    if optionID==mcm.oid_followingNPCsitToggle
        Repository.followingNPCsit=!Repository.followingNPCsit
        mcm.SetToggleOptionValue(mcm.oid_followingNPCsitToggle, Repository.followingNPCsit)
		if (Repository.followingNPCsit)== True 
			game.getplayer().addtofaction( Repository.giafac_sitters)
		elseif (Repository.followingNPCsit)== False
			game.getplayer().removefromfaction( Repository.giafac_sitters)
		endif
    endif
	
	if optionID==mcm.oid_followingNPCsleepToggle
        Repository.followingNPCsleep=!Repository.followingNPCsleep
        mcm.SetToggleOptionValue(mcm.oid_followingNPCsleepToggle, Repository.followingNPCsleep)
		if (Repository.followingNPCsleep)== True 
			game.getplayer().addtofaction( Repository.giafac_sleepers)
		elseif (Repository.followingNPCsleep)== False
			game.getplayer().removefromfaction( Repository.giafac_sleepers)
		endif
    endif
	if optionID==mcm.oid_NPCstopandTalkToggle
        Repository.NPCstopandTalk=!Repository.NPCstopandTalk
        mcm.SetToggleOptionValue(mcm.oid_NPCstopandTalkToggle, Repository.NPCstopandTalk)
		if (Repository.NPCstopandTalk)== True 
			game.getplayer().addtofaction( Repository.giafac_TalktoMe)
		elseif (Repository.NPCstopandTalk)== False
			game.getplayer().removefromfaction( Repository.giafac_TalktoMe)
		endif
	endif
	if optionID==mcm.oid_AllowForNPCtoFollowToggle
        Repository.AllowForNPCtoFollow=!Repository.AllowForNPCtoFollow
        mcm.SetToggleOptionValue(mcm.oid_AllowForNPCtoFollowToggle, Repository.AllowForNPCtoFollow)
		if (Repository.AllowForNPCtoFollow)== True 
			game.getplayer().addtofaction( Repository.giafac_AllowFollower)
		elseif (Repository.AllowForNPCtoFollow)== False
			game.getplayer().removefromfaction( Repository.giafac_AllowFollower)
		endif
		;MantellaMCM_FollowingNPCSettings.Render(self, repository)
		;debug.messagebox("Click on another option then return to see changes and refresh this page until @YetAnotherModder can help me autorefresh it.")
	endif
	if optionID==mcm.oid_NPCAngerToggle
        Repository.NPCAnger=!Repository.NPCAnger
        mcm.SetToggleOptionValue(mcm.oid_NPCAngerToggle, Repository.NPCAnger)
		if (Repository.NPCAnger)== True 
			game.getplayer().addtofaction( Repository.giafac_AllowAnger)
		elseif (Repository.NPCAnger)== False
			game.getplayer().removefromfaction( Repository.giafac_AllowAnger)
		endif
	endif
	if optionID==mcm.oid_NPCForgiveToggle
        Repository.NPCForgive=!Repository.NPCForgive
        mcm.SetToggleOptionValue(mcm.oid_NPCForgiveToggle, Repository.NPCForgive)
		if (Repository.NPCForgive)== True 
			game.getplayer().addtofaction( Repository.giafac_AllowForgive)
		elseif (Repository.NPCForgive)== False
			game.getplayer().removefromfaction( Repository.giafac_AllowForgive)
		endif
	endif		
	
	if optionID==mcm.oid_NPCDialogueToggle
        Repository.NPCDialogue=!Repository.NPCDialogue
        mcm.SetToggleOptionValue(mcm.oid_NPCDialogueToggle, Repository.NPCDialogue)
		if (Repository.NPCDialogue)== True 
			game.getplayer().addtofaction( Repository.giafac_AllowDialogue)
		elseif (Repository.NPCDialogue)== False
			game.getplayer().removefromfaction( Repository.giafac_AllowDialogue)
		endif
	endif		
	
endfunction 
