Scriptname MantellaEffectScript extends activemagiceffect

Topic property MantellaDialogueLine auto

event OnEffectStart(Actor target, Actor caster)
    ;MiscUtil.WriteToFile("dialogue_id.txt", MantellaDialogueLine, append=false)
    MiscUtil.WriteToFile("_mantella__skyrim_folder.txt", "Set the folder this file is in as your skyrim_folder path in MantellaSoftware/config.ini", append=false)
	; only run script if actor is not already selected (doesn't work)
	String currentActor = MiscUtil.ReadFromFile("_mantella_current_actor.txt") as String
    Utility.Wait(0.5)
	if currentActor == ""
        ; end any other conversations before starting this one (doesn't work)
        ;MiscUtil.WriteToFile("end_conversation.txt", "True",  append=false)

        ; Get NPC's name and save name to current_actor.txt for Pyton to read
        String actorName = (target.getactorbase() as form).getname()
        MiscUtil.WriteToFile("_mantella_current_actor.txt", actorName, append=false)
        Debug.Notification("Starting conversation with " + actorName)

        String actorSex = target.getactorbase().getsex()
        MiscUtil.WriteToFile("_mantella_actor_sex.txt", actorSex, append=false)

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
                Debug.Notification(subtitle)

                target.Say(MantellaDialogueLine)
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

            ; Update time (this may be too frequent)
            Time = GetCurrentHourOfDay()
            MiscUtil.WriteToFile("_mantella_in_game_time.txt", Time, append=false)

            ; Wait for Python / the "ChatAIEndConversationScript" script to give the green light to end the conversation
            endConversation = MiscUtil.ReadFromFile("_mantella_end_conversation.txt") as String
        endWhile
    else
        MiscUtil.WriteToFile("_mantella_end_conversation.txt", "True",  append=false)
    endIf
	Debug.Notification("Conversation ended.")
endEvent

int Function GetCurrentHourOfDay()
	float Time = Utility.GetCurrentGameTime()
	Time -= Math.Floor(Time) ; Remove "previous in-game days passed" bit
	Time *= 24 ; Convert from fraction of a day to number of hours
	int Hour = Math.Floor(Time) ; Get whole hour
	Return Hour
EndFunction