Scriptname MantellaEffectScript extends activemagiceffect

Topic property MantellaDialogueLine auto
ReferenceAlias property TargetRefAlias auto

event OnEffectStart(Actor target, Actor caster)
    MiscUtil.WriteToFile("_mantella__skyrim_folder.txt", "Set the folder this file is in as your skyrim_folder path in MantellaSoftware/config.ini", append=false)
	; only run script if actor is not already selected
	String currentActor = MiscUtil.ReadFromFile("_mantella_current_actor.txt") as String

    MiscUtil.WriteToFile("_mantella_text_input_enabled.txt", "False", append=False)
    MiscUtil.WriteToFile("_mantella_text_input.txt", "", append=false)

    Utility.Wait(0.5)

	if currentActor == ""
        TargetRefAlias.ForceRefTo(target)

        String actorId = (target.getactorbase() as form).getformid()
        MiscUtil.WriteToFile("_mantella_current_actor_id.txt", actorId, append=false)

        ; Get NPC's name and save name to _mantella_current_actor.txt for Python to read
        String actorName = (target.getleveledactorbase() as form).getname()
        MiscUtil.WriteToFile("_mantella_current_actor.txt", actorName, append=false)
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

        ; Start conversation
        While endConversation == "False"
            playerResponse = MiscUtil.ReadFromFile("_mantella_text_input_enabled.txt") as String
            if playerResponse == "True"
                GetPlayerInput()
                Utility.Wait(3)
            endIf

            sayLine = MiscUtil.ReadFromFile("_mantella_say_line.txt") as String
            if sayLine == "True"
                subtitle = MiscUtil.ReadFromFile("_mantella_subtitle.txt") as string

                target.Say(MantellaDialogueLine, abSpeakInPlayersHead=false)

                ; Set sayLine back to False once the voiceline has been triggered
                MiscUtil.WriteToFile("_mantella_say_line.txt", "False",  append=false)
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

            ; Update time (this may be too frequent)
            Time = GetCurrentHourOfDay()
            MiscUtil.WriteToFile("_mantella_in_game_time.txt", Time, append=false)

            if sayFinalLine == "True"
                endConversation = "True"
            endIf

            ; Wait for Python / the script to give the green light to end the conversation
            sayFinalLine = MiscUtil.ReadFromFile("_mantella_end_conversation.txt") as String
        endWhile
    else
        MiscUtil.WriteToFile("_mantella_end_conversation.txt", "True",  append=false)
    endIf
	Debug.Notification("Conversation ended.")
endEvent


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


function GetPlayerInput()
    UIExtensions.InitMenu("UITextEntryMenu")
    UIExtensions.OpenMenu("UITextEntryMenu")

    string result = UIExtensions.GetMenuResultString("UITextEntryMenu")

    MiscUtil.WriteToFile("_mantella_text_input_enabled.txt", "False", append=False)
    MiscUtil.WriteToFile("_mantella_text_input.txt", result, append=false)
endFunction
