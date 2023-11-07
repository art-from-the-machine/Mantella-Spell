Scriptname MantellaEffectScript extends activemagiceffect

Topic property MantellaDialogueLine auto
ReferenceAlias property TargetRefAlias auto
Faction property DunPlayerAllyFactionProperty auto
Faction property PotentialFollowerFactionProperty auto
int localMenuTimer = 0

event OnEffectStart(Actor target, Actor caster)
	; these three lines below is to ensure that no leftover Mantella effects are running
	;MiscUtil.WriteToFile("_mantella_end_conversation.txt", "True",  append=false)
	;Utility.Wait(0.5)
	;MiscUtil.WriteToFile("_mantella_end_conversation.txt", "False",  append=false)
    
    MiscUtil.WriteToFile("_mantella__skyrim_folder.txt", "Set the folder this file is in as your skyrim_folder path in MantellaSoftware/config.ini", append=false)
	; only run script if actor is not already selected
	String currentActor = MiscUtil.ReadFromFile("_mantella_current_actor.txt") as String

    MiscUtil.WriteToFile("_mantella_text_input_enabled.txt", "False", append=False)
    MiscUtil.WriteToFile("_mantella_text_input.txt", "", append=false)

    Utility.Wait(0.5)

	;if currentActor == ""
    TargetRefAlias.ForceRefTo(target)

    String actorId = (target.getactorbase() as form).getformid()
    if caster.IsSneaking() == 1
        UIExtensions.InitMenu("UITextEntryMenu")
        UIExtensions.OpenMenu("UITextEntryMenu")
        string result1 = UIExtensions.GetMenuResultString("UITextEntryMenu")
        MiscUtil.WriteToFile("_mantella_current_actor_id.txt", result1, append=false)
    else
        MiscUtil.WriteToFile("_mantella_current_actor_id.txt", actorId, append=false)
    endIf

    ; Get NPC's name and save name to _mantella_current_actor.txt for Python to read
    String actorName = target.getdisplayname()
    if caster.IsSneaking() == 1
        UIExtensions.InitMenu("UITextEntryMenu")
        UIExtensions.OpenMenu("UITextEntryMenu")
        string result2 = UIExtensions.GetMenuResultString("UITextEntryMenu")
        MiscUtil.WriteToFile("_mantella_current_actor.txt", result2, append=false)
    else
        MiscUtil.WriteToFile("_mantella_current_actor.txt", actorName, append=false)
    endIf
    Debug.Notification("Starting conversation with " + actorName)
    
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

    String sayLine = "False"
    String playerResponse = "False"
    String subtitle = ""
    String endConversation = "False"
    String sayFinalLine = "False"
    String listening = "False"

    ; Wait for first voiceline to play to avoid old conversation playing
    Utility.Wait(0.5)

    ;ConversationLoop()

    ; Start conversation
    While endConversation == "False"
        playerResponse = MiscUtil.ReadFromFile("_mantella_text_input_enabled.txt") as String
        if playerResponse == "True"
            StartTimer()
            Utility.Wait(2)
        endIf

        sayLine = MiscUtil.ReadFromFile("_mantella_say_line.txt") as String
        if sayLine == "True"
            subtitle = MiscUtil.ReadFromFile("_mantella_subtitle.txt") as String
            
            MantellaSubtitles.SetInjectTopicAndSubtitleForSpeaker(target, MantellaDialogueLine, subtitle)
            target.Say(MantellaDialogueLine, abSpeakInPlayersHead=false)

            ; Set sayLine back to False once the voiceline has been triggered
            MiscUtil.WriteToFile("_mantella_say_line.txt", "False",  append=false)
            localMenuTimer = -1
        endIf

        listening = MiscUtil.ReadFromFile("_mantella_listening.txt") as String
        if listening == "True"
            Debug.Notification("Listening...")
            MiscUtil.WriteToFile("_mantella_listening.txt", "False",  append=false)
        endIf

        String thinking = MiscUtil.ReadFromFile("_mantella_thinking.txt") as String
        if thinking == "True"
            Debug.Notification("Thinking...")
            MiscUtil.WriteToFile("_mantella_thinking.txt", "False",  append=false)
        endIf

        String exe_error = MiscUtil.ReadFromFile("_mantella_error_check.txt") as String
        if exe_error == "True"
            Debug.Notification("Error with Mantella.exe. Please check MantellaSoftware/logging.log")
            MiscUtil.WriteToFile("_mantella_error_check.txt", "False",  append=false)
        endIf

        String aggro = MiscUtil.ReadFromFile("_mantella_aggro.txt") as String
        if aggro == "0"
            Debug.Notification(actorName + " forgave you.")
            target.StopCombat()
            MiscUtil.WriteToFile("_mantella_aggro.txt", "",  append=false)
        elseIf aggro == "1"
            Debug.Notification(actorName + " did not like that.")
            ;target.UnsheatheWeapon()
            ;target.SendTrespassAlarm(caster)
            target.StartCombat(caster)
            MiscUtil.WriteToFile("_mantella_aggro.txt", "",  append=false)
        elseif aggro == "2"
            if actorRelationship != "4"
                Debug.Notification(actorName + " is willing to follow you.")
                target.setrelationshiprank(caster, 4)
                target.addtofaction(DunPlayerAllyFactionProperty)
                target.addtofaction(PotentialFollowerFactionProperty)
                MiscUtil.WriteToFile("_mantella_aggro.txt", "",  append=false)
            endIf
        endIf

        ; Update time (this may be too frequent)
        Time = GetCurrentHourOfDay()
        MiscUtil.WriteToFile("_mantella_in_game_time.txt", Time, append=false)

        if sayFinalLine == "True"
            endConversation = "True"
            localMenuTimer = -1
        endIf

        ; Wait for Python / the script to give the green light to end the conversation
        sayFinalLine = MiscUtil.ReadFromFile("_mantella_end_conversation.txt") as String
    endWhile
    ;else
    ;    MiscUtil.WriteToFile("_mantella_end_conversation.txt", "True",  append=false)
    ;endIf
	Debug.Notification("Conversation ended.")
endEvent


function ConversationLoop()
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
	localMenuTimer = MiscUtil.ReadFromFile("_mantella_response_timer.txt") as int
	Debug.Notification("Awaiting player input for "+localMenuTimer+" seconds")
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
