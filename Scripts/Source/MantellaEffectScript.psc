Scriptname MantellaEffectScript extends activemagiceffect

Topic property MantellaDialogueLine auto
ReferenceAlias property TargetRefAlias auto
;Faction property DunPlayerAllyFactionProperty auto
;Faction property PotentialFollowerFactionProperty auto

;#############
float localMenuTimer = 0.0
;#############
MantellaRepository property repository auto

event OnEffectStart(Actor target, Actor caster)
	; these three lines below is to ensure that no leftover Mantella effects are running
	;MiscUtil.WriteToFile("_mantella_end_conversation.txt", "True",  append=false)
	;Utility.Wait(0.5)
	;MiscUtil.WriteToFile("_mantella_end_conversation.txt", "False",  append=false)
    
    MiscUtil.WriteToFile("_mantella__skyrim_folder.txt", "Set the folder this file is in as your skyrim_folder path in MantellaSoftware/config.ini", append=false)
    String activeActors = MiscUtil.ReadFromFile("_mantella_active_actors.txt") as String
    int actorCount = MiscUtil.ReadFromFile("_mantella_actor_count.txt") as int
    String character_selection_enabled = MiscUtil.ReadFromFile("_mantella_character_selection.txt") as String

    Utility.Wait(0.5)

    String actorName = target.getdisplayname()
    String casterName = caster.getdisplayname()

    ;if radiant dialogue between two NPCs, label them 1 & 2
    if (casterName == actorName)
        if actorCount == 0
            actorName = actorName + " 1"
            casterName = casterName + " 2"
        elseIf actorCount == 1
            actorName = actorName + " 2"
            casterName = casterName + " 1"
        endIf
    endIf

    int index = StringUtil.Find(activeActors, actorName)
    bool actorAlreadyLoaded = true
    if index == -1
        actorAlreadyLoaded = false
    endIf

    String radiantDialogue = MiscUtil.ReadFromFile("_mantella_radiant_dialogue.txt") as String
    ; if radiant dialogue is active without the actor selected by player, end the radiant dialogue
    if (radiantDialogue == "True") && (caster == Game.GetPlayer()) && (actorAlreadyLoaded == false)
        Debug.Notification("Ending radiant dialogue")
        MiscUtil.WriteToFile("_mantella_end_conversation.txt", "True",  append=false)
    ; if selected actor is in radiant dialogue, disable this mode to allow the player to join the conversation
    elseIf (radiantDialogue == "True") && (actorAlreadyLoaded == true) && (caster == Game.GetPlayer())
        Debug.Notification("Adding player to conversation")
        MiscUtil.WriteToFile("_mantella_radiant_dialogue.txt", "False",  append=false)
    ; if actor not already loaded and character selection is enabled
	elseIf (actorAlreadyLoaded == false) && (character_selection_enabled == "True")
        TargetRefAlias.ForceRefTo(target)

        String actorId = (target.getactorbase() as form).getformid()
        ;if debug select mode is active this will allow the user to enter in the RefID of the NPC bio/voice to have a conversation with
		if repository.NPCdebugSelectModeEnabled==true
            Debug.Messagebox("Enter the actor's RefID(in base 10) that you wish to speak to")
            Utility.Wait(0.1)
			UIExtensions.InitMenu("UITextEntryMenu")
			UIExtensions.OpenMenu("UITextEntryMenu")
			string result1 = UIExtensions.GetMenuResultString("UITextEntryMenu")
			MiscUtil.WriteToFile("_mantella_current_actor_id.txt", result1, append=false)
		else
		    MiscUtil.WriteToFile("_mantella_current_actor_id.txt", actorId, append=false)
		endIf

        ; Get NPC's name and save name to _mantella_current_actor.txt for Python to read
        ;if debug select mode is active this will allow the user to enter in the RefID of the NPC bio/voice to have a conversation with
		if repository.NPCdebugSelectModeEnabled==true
            Debug.Messagebox("Enter the name of the actor that you wish to speak to")
            Utility.Wait(0.1)
			UIExtensions.InitMenu("UITextEntryMenu")
			UIExtensions.OpenMenu("UITextEntryMenu")
			string result2 = UIExtensions.GetMenuResultString("UITextEntryMenu")
			MiscUtil.WriteToFile("_mantella_current_actor.txt", result2, append=false)
            MiscUtil.WriteToFile("_mantella_active_actors.txt", " "+actorName+" ", append=true)
            MiscUtil.WriteToFile("_mantella_character_selection.txt", "False", append=false)
		else
			MiscUtil.WriteToFile("_mantella_current_actor.txt", actorName, append=false)
            MiscUtil.WriteToFile("_mantella_active_actors.txt", " "+actorName+" ", append=true)
            MiscUtil.WriteToFile("_mantella_character_selection.txt", "False", append=false)
		endIf
		target.addtofaction(repository.giafac_Mantella);gia
		
        String actorSex = target.getleveledactorbase().getsex()
        MiscUtil.WriteToFile("_mantella_actor_sex.txt", actorSex, append=false)

        String actorRace = target.getrace()
        MiscUtil.WriteToFile("_mantella_actor_race.txt", actorRace, append=false)

        String actorRelationship = target.getrelationshiprank(game.getplayer())
        MiscUtil.WriteToFile("_mantella_actor_relationship.txt", actorRelationship, append=false)

        String actorVoiceType = target.GetVoiceType()
        MiscUtil.WriteToFile("_mantella_actor_voice.txt", actorVoiceType, append=false)

        String isEnemy = "False"
        if (target.getcombattarget() == game.getplayer())
            isEnemy = "True"
        endIf
        MiscUtil.WriteToFile("_mantella_actor_is_enemy.txt", isEnemy, append=false)

        String currLoc = (caster.GetCurrentLocation() as form).getname()
        if currLoc == ""
            currLoc = "Skyrim"
        endIf
        MiscUtil.WriteToFile("_mantella_current_location.txt", currLoc, append=false)

        int Time
        Time = GetCurrentHourOfDay()
        MiscUtil.WriteToFile("_mantella_in_game_time.txt", Time, append=false)

        actorCount += 1
        MiscUtil.WriteToFile("_mantella_actor_count.txt", actorCount, append=false)

        if actorCount == 1 ; reset player input if this is the first actor selected
            MiscUtil.WriteToFile("_mantella_text_input_enabled.txt", "False", append=False)
            MiscUtil.WriteToFile("_mantella_text_input.txt", "", append=false)
            MiscUtil.WriteToFile("_mantella_in_game_events.txt", "", append=False)
        endif

        if (caster == game.getplayer()) && actorCount == 1
		    Debug.Notification("Starting conversation with " + actorName)
        elseIf (caster == game.getplayer()) && actorCount >1
                Debug.Notification("Adding " + actorName + " to conversation")
        elseIf actorCount == 1
            Debug.Notification("Starting radiant dialogue with " + actorName + " and " + casterName)
        endIf

        String endConversation = "False"
        String sayFinalLine = "False"
        String sayLineFile = "_mantella_say_line_"+actorCount+".txt"
        Int loopCount = 0

        ; Wait for first voiceline to play to avoid old conversation playing
        Utility.Wait(0.5)

        MiscUtil.WriteToFile("_mantella_character_selected.txt", "True", append=false)

        ; Start conversation
        While endConversation == "False"
            if actorCount == 1
                MainConversationLoop(target, caster, actorName, actorRelationship, loopCount)
                loopCount += 1
            else
                ConversationLoop(target, caster, actorName, sayLineFile)
            endif
            
            if sayFinalLine == "True"
                endConversation = "True"
                localMenuTimer = -1
            endIf

            ; Wait for Python / the script to give the green light to end the conversation
            sayFinalLine = MiscUtil.ReadFromFile("_mantella_end_conversation.txt") as String
        endWhile
		target.removefromfaction(repository.giafac_Mantella);gia
        radiantDialogue = MiscUtil.ReadFromFile("_mantella_radiant_dialogue.txt") as String
        if radiantDialogue == "True"
            Debug.Notification("Radiant dialogue ended.")
        else
            Debug.Notification("Conversation ended.")
        endIf
        target.ClearLookAt()
        caster.ClearLookAt()
        MiscUtil.WriteToFile("_mantella_actor_count.txt", "0", append=False)
    else
        Debug.Notification("NPC not added. Please try again after your next response.")
    endIf
endEvent


function MainConversationLoop(Actor target, Actor caster, String actorName, String actorRelationship, Int loopCount)
    String sayLine = MiscUtil.ReadFromFile("_mantella_say_line.txt") as String
    if sayLine != "False"
        ;Debug.Notification(actorName + " is speaking.")
        MantellaSubtitles.SetInjectTopicAndSubtitleForSpeaker(target, MantellaDialogueLine, sayLine)
        target.Say(MantellaDialogueLine, abSpeakInPlayersHead=false)
        target.SetLookAt(caster)

        ; Set sayLine back to False once the voiceline has been triggered
        MiscUtil.WriteToFile("_mantella_say_line.txt", "False",  append=false)
        localMenuTimer = -1

        ; Check aggro status after every line spoken
        String aggro = MiscUtil.ReadFromFile("_mantella_aggro.txt") as String
        if aggro == "0"
            if game.getplayer().isinfaction(Repository.giafac_AllowAnger)
                Debug.Notification(actorName + " forgave you.")
                target.StopCombat()
			endif
            MiscUtil.WriteToFile("_mantella_aggro.txt", "",  append=false)
        elseIf aggro == "1"
            if game.getplayer().isinfaction(Repository.giafac_AllowAnger)
                Debug.Notification(actorName + " did not like that.")
                ;target.UnsheatheWeapon()
                ;target.SendTrespassAlarm(caster)
                target.StartCombat(caster)
            else
                Debug.Notification("Aggro action not enabled in the Mantella MCM.")
			Endif
            MiscUtil.WriteToFile("_mantella_aggro.txt", "",  append=false)
        elseif aggro == "2"
            if actorRelationship != "4"
                ;Debug.Notification(actorName + " is willing to follow you.")
                ;target.setrelationshiprank(caster, 4)
                ;target.addtofaction(DunPlayerAllyFactionProperty)
                ;target.addtofaction(PotentialFollowerFactionProperty)
                if game.getplayer().isinfaction(repository.giafac_allowfollower)
					Debug.Notification(actorName + " is following you.");gia
					target.SetFactionRank(repository.giafac_following, 1);gia
					repository.gia_FollowerQst.reset();gia
					repository.gia_FollowerQst.stop();gia
					Utility.Wait(0.5);gia
					repository.gia_FollowerQst.start();gia
					target.EvaluatePackage();gia
                else
                    Debug.Notification("Follow action not enabled in the Mantella MCM.")
				endif

                MiscUtil.WriteToFile("_mantella_aggro.txt", "",  append=false)
            endIf
        endIf

        ; Update time (this may be too frequent)
        int Time = GetCurrentHourOfDay()
        MiscUtil.WriteToFile("_mantella_in_game_time.txt", Time, append=false)

        caster.SetLookAt(target)
    endIf

    ; Run these checks every 5 loops
    if loopCount % 5 == 0
        String status = MiscUtil.ReadFromFile("_mantella_status.txt") as String
        if status != "False"
            Debug.Notification(status)
            MiscUtil.WriteToFile("_mantella_status.txt", "False",  append=false)
        endIf

        String playerResponse = MiscUtil.ReadFromFile("_mantella_text_input_enabled.txt") as String
        if playerResponse == "True"
            StartTimer()
            Utility.Wait(2)
        endIf

        if loopCount % 20 == 0
            target.ClearLookAt()
            caster.ClearLookAt()
            String radiantDialogue = MiscUtil.ReadFromFile("_mantella_radiant_dialogue.txt") as String
            if radiantDialogue == "True"
                float distanceBetweenActors = caster.GetDistance(target)
                float distanceToPlayer = ConvertGameUnitsToMeter(caster.GetDistance(game.getplayer()))
                ;Debug.Notification(distanceBetweenActors)
                ;TODO: allow distanceBetweenActos limit to be customisable
                if (distanceBetweenActors > 1500) || (distanceToPlayer > repository.radiantDistance) || (caster.GetCurrentLocation() != target.GetCurrentLocation()) || (caster.GetCurrentScene() != None) || (target.GetCurrentScene() != None)
                    ;Debug.Notification(distanceBetweenActors)
                    MiscUtil.WriteToFile("_mantella_end_conversation.txt", "True",  append=false)
                endIf
            endIf
        endIf
    endIf
endFunction


function ConversationLoop(Actor target, Actor caster, String actorName, String sayLineFile)
    String sayLine = MiscUtil.ReadFromFile(sayLineFile) as String
    if sayLine != "False"
        ;Debug.Notification(actorName + " is speaking.")
        MantellaSubtitles.SetInjectTopicAndSubtitleForSpeaker(target, MantellaDialogueLine, sayLine)
        target.Say(MantellaDialogueLine, abSpeakInPlayersHead=false)
        ;target.SetLookAt(caster)

        ; Set sayLine back to False once the voiceline has been triggered
        MiscUtil.WriteToFile(sayLineFile, "False",  append=false)
        localMenuTimer = -1
    endIf
endFunction


int function GetCurrentHourOfDay()
	float Time = Utility.GetCurrentGameTime()
	Time -= Math.Floor(Time) ; Remove "previous in-game days passed" bit
	Time *= 24 ; Convert from fraction of a day to number of hours
	int Hour = Math.Floor(Time) ; Get whole hour
	return Hour
endFunction


function SplitSubtitleIntoParts(String subtitle)
    String[] subtitles = PapyrusUtil.StringSplit(subtitle, ",")
    int subtitleNo = 0
    while (subtitleNo < subtitles.Length)
        Debug.Notification(subtitles[subtitleNo])
        subtitleNo += 1
    endwhile
endFunction


function StartTimer()
	localMenuTimer=180
    ;#################################################
	localMenuTimer = repository.MantellaEffectResponseTimer
    ;################################################
    int localMenuTimerInt = Math.Floor(localMenuTimer)
	Debug.Notification("Awaiting player input for "+localMenuTimerInt+" seconds")
	String Monitorplayerresponse
	String timerCheckEndConversation
	;Debug.Notification("Timer is "+localMenuTimer)
	While localMenuTimer >= 0
		;Debug.Notification("Timer is "+localMenuTimer)
		Monitorplayerresponse = MiscUtil.ReadFromFile("_mantella_text_input_enabled.txt") as String
		timerCheckEndConversation = MiscUtil.ReadFromFile("_mantella_end_conversation.txt") as String
		;the next if clause checks if another conversation is already running and ends it.
		if timerCheckEndConversation == "true"
			localMenuTimer = -1
			MiscUtil.WriteToFile("_mantella_say_line.txt", "False", append=false)
			return
		endif
		if Monitorplayerresponse == "False"
			localMenuTimer = -1
		endif
		If localMenuTimer > 0
			Utility.Wait(1)
			if !utility.IsInMenuMode()
				localMenuTimer = localMenuTimer - 1
			endif
			;Debug.Notification("Timer is "+localMenuTimer)
		elseif localMenuTimer == 0
			Monitorplayerresponse = "False"
			;added this as a safety check in case the player stays in a menu a long time.
			Monitorplayerresponse = MiscUtil.ReadFromFile("_mantella_text_input_enabled.txt") as String
			if Monitorplayerresponse == "True"
				;Debug.Notification("opening menu now")
				GetPlayerInput()
			endIf
			localMenuTimer = -1
		endIf
	endWhile
endFunction

function GetPlayerInput()
    UIExtensions.InitMenu("UITextEntryMenu")
    UIExtensions.OpenMenu("UITextEntryMenu")

    string result = UIExtensions.GetMenuResultString("UITextEntryMenu")

    MiscUtil.WriteToFile("_mantella_text_input_enabled.txt", "False", append=False)
    MiscUtil.WriteToFile("_mantella_text_input.txt", result, append=false)
endFunction

Float meterUnits = 71.0210
Float Function ConvertMeterToGameUnits(Float meter)
    Return Meter * meterUnits
EndFunction

Float Function ConvertGameUnitsToMeter(Float gameUnits)
    Return gameUnits / meterUnits
EndFunction