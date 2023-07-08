Scriptname MantellaEffectScript extends activemagiceffect

Topic property MantellaDialogueLine auto

event OnEffectStart(Actor target, Actor caster)
    MiscUtil.WriteToFile("dialogue_id.txt", MantellaDialogueLine, append=false)
	; only run script if actor is not already selected (doesn't work)
	String currentActor = MiscUtil.ReadFromFile("current_actor.txt") as String
    Utility.Wait(0.5)
	if currentActor == ""
        ; end any other conversations before starting this one (doesn't work)
        ;MiscUtil.WriteToFile("end_conversation.txt", "True",  append=false)

        ; Get NPC's name and save name to current_actor.txt for Pyton to read
        String actorName = (target.getactorbase() as form).getname()
        MiscUtil.WriteToFile("current_actor.txt", actorName, append=false)
        Debug.Notification("Starting conversation with " + actorName)

        ; Get current location and save to current_location.txt for Python to read
        String currLoc = (caster.GetCurrentLocation() as form).getname()
        if currLoc == ""
            currLoc = "Skyrim"
        endIf
        MiscUtil.WriteToFile("current_location.txt", currLoc, append=false)
        ;Debug.MessageBox("Current location is " + currLoc)

        int Time;
        Time = GetCurrentHourOfDay()
        MiscUtil.WriteToFile("in_game_time.txt", Time, append=false)
        ;Debug.MessageBox("Current time is " + Time)

        ;Topic helloTopicTopic = Game.GetFormFromFile(0x01001D8A, "Mantella.esp") as Topic ;  0x01001D8B 0x01001827

        String sayLine = "False"
        String endConversation = "False"
        ;bool bBreak = False

        ; Start conversation
        While endConversation == "False"
            ; Wait for Python to give the green light to say the voiceline
            ;Utility.Wait(0.1)
            sayLine = MiscUtil.ReadFromFile("say_line.txt") as String
            if sayLine == "True"
                ;Utility.Wait(0.25)
                ;Debug.Notification("This message is displayed on the HUD menu.")
                target.Say(MantellaDialogueLine)
                ; Set sayLine back to False once the voiceline has been triggered
                MiscUtil.WriteToFile("say_line.txt", "False",  append=false)
            endIf

            ; Update time (this may be too frequent)
            Time = GetCurrentHourOfDay()
            MiscUtil.WriteToFile("in_game_time.txt", Time, append=false)

            ; Wait for Python / the "ChatAIEndConversationScript" script to give the green light to end the conversation
            endConversation = MiscUtil.ReadFromFile("end_conversation.txt") as String
        endWhile
    else
        MiscUtil.WriteToFile("end_conversation.txt", "True",  append=false)
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