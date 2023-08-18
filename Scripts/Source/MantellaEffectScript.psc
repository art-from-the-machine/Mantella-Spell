Scriptname MantellaEffectScript extends activemagiceffect

Topic property MantellaDialogueLine auto

event OnEffectStart(Actor target, Actor caster)
    ;MiscUtil.WriteToFile("dialogue_id.txt", MantellaDialogueLine, append=false)
    MiscUtil.WriteToFile("_mantella__skyrim_folder.txt", "Set the folder this file is in as your skyrim_folder path in MantellaSoftware/config.ini", append=false)
	; only run script if actor is not already selected
	String currentActor = MiscUtil.ReadFromFile("_mantella_current_actor.txt") as String
    Utility.Wait(0.5)

	if currentActor == ""
        String actorId = (target.getactorbase() as form).getformid()
        MiscUtil.WriteToFile("_mantella_current_actor_id.txt", actorId, append=false)

        ; Get NPC's name and save name to current_actor.txt for Pyton to read
        String actorName = (target.getleveledactorbase() as form).getname()
        MiscUtil.WriteToFile("_mantella_current_actor.txt", actorName, append=false)
        Debug.Notification("Starting conversation with " + actorName)

        String actorSex = target.getleveledactorbase().getsex()
        MiscUtil.WriteToFile("_mantella_actor_sex.txt", actorSex, append=false)

        String actorRace = target.getrace()
        MiscUtil.WriteToFile("_mantella_actor_race.txt", actorRace, append=false)

        ;String actorRelationship = target.getrelationshiprank(game.getplayer())
        ;MiscUtil.WriteToFile("_mantella_actor_relationship.txt", actorRelationship, append=false)

        String actorVoiceType = target.GetVoiceType()
        MiscUtil.WriteToFile("_mantella_actor_voice.txt", actorVoiceType, append=false)

        String isEnemy = "False"
        if (target.getcombattarget() == game.getplayer())
            isEnemy = "True"
        endIf
        MiscUtil.WriteToFile("_mantella_actor_is_enemy.txt", isEnemy, append=false)

        ; Get current location and save to current_location.txt for Python to read
        String currLoc = (caster.GetCurrentLocation() as form).getname()
        if currLoc == ""
            currLoc = "Skyrim"
        endIf
        MiscUtil.WriteToFile("_mantella_current_location.txt", currLoc, append=false)
        ;Debug.MessageBox("Current location is " + currLoc)

        int Time
        Time = GetCurrentHourOfDay()
        MiscUtil.WriteToFile("_mantella_in_game_time.txt", Time, append=false)
        ;Debug.MessageBox("Current time is " + Time)

        ;Topic helloTopicTopic = Game.GetFormFromFile(0x01001D8A, "Mantella.esp") as Topic ;  0x01001D8B 0x01001827

        String sayLine = "False"
        String subtitle = ""
        String endConversation = "False"
        String sayFinalLine = "False"
        String listening = "False"

        ; Wait for first voiceline to play to avoid old conversation playiing
        Utility.Wait(0.5)

        ; Start conversation
        While endConversation == "False"
            ; Wait for Python to give the green light to say the voiceline
            ;Utility.Wait(0.1)
            sayLine = MiscUtil.ReadFromFile("_mantella_say_line.txt") as String
            if sayLine == "True"
                subtitle = MiscUtil.ReadFromFile("_mantella_subtitle.txt") as String
                if subtitle != ""
                    String[] subtitles = SplitSubtitleIntoParts(subtitle)
                endIf
                
                target.Say(MantellaDialogueLine, abSpeakInPlayersHead=true)
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

            ; Wait for Python / the "ChatAIEndConversationScript" script to give the green light to end the conversation
            sayFinalLine = MiscUtil.ReadFromFile("_mantella_end_conversation.txt") as String

            if target.IsDead()
                MiscUtil.WriteToFile("_mantella_end_conversation.txt", "True",  append=false)
                endConversation = "True"
            endIf

            if game.getplayer().IsDead()
                MiscUtil.WriteToFile("_mantella_end_conversation.txt", "True",  append=false)
                endConversation = "True"
            endIf
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