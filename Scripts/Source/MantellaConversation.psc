Scriptname MantellaConversation extends Quest hidden

Import SKSE_HTTP
Import Utility

Topic property MantellaDialogueLine auto
MantellaRepository property repository auto
MantellaConstants property mConsts auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;           Globals           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Form[] _actorsInConversation
float _localMenuTimer = 0.0
String[] _ingameEvents

event OnInit()    
    RegisterForModEvent("SKSE_HTTP_OnHttpReplyReceived","OnHttpReplyReceived")
endEvent



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    Continue conversation    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

event OnHttpReplyReceived(int typedDictionaryHandle)
    string replyType = SKSE_HTTP.getString(typedDictionaryHandle, GetFullKey(mConsts.KEY_REPLYTYPE),"error")
    If (replyType != "error")
        ContinueConversation(typedDictionaryHandle)
    EndIf
endEvent

function ContinueConversation(int handle)
    string nextAction = SKSE_HTTP.getString(handle, GetFullKey(mConsts.KEY_REPLYTYPE), "Error: Did not receive reply type")
    Debug.Notification(nextAction)
    if(nextAction == mConsts.ACTION_NPCTALK)
        string speakerName = SKSE_HTTP.getString(handle, GetFullKey(mConsts.KEY_ACTOR_SPEAKER), "Error: No speaker transmitted for action 'NPC talk'")
        Actor speaker = GetActorInConversation(speakerName) 
        if speaker != none
            string lineToSpeak = SKSE_HTTP.getString(handle, GetFullKey(mConsts.KEY_ACTOR_LINETOSPEAK), "Error: No line transmitted for actor to speak")
            NpcSpeak(speaker, lineToSpeak, Game.GetPlayer())
        endIf
    elseIf(nextAction == mConsts.ACTION_PLAYERTALK)
        If (repository.microphoneEnabled)
            sendRequestForVoiceTranscribe()
        Else
            StartTimer()
        EndIf
    elseIf(nextAction == mConsts.ACTION_ENDCONVERSATION)
        EndConversation()
    endIf
endFunction

function NpcSpeak(Actor actorSpeaking, string lineToSay, Actor actorToSpekTo)
    MantellaSubtitles.SetInjectTopicAndSubtitleForSpeaker(actorSpeaking, MantellaDialogueLine, lineToSay)
    actorSpeaking.Say(MantellaDialogueLine, abSpeakInPlayersHead=false)
    actorSpeaking.SetLookAt(actorToSpekTo)
endfunction

Actor function GetActorInConversation(string actorName)
    int i = 0
    While i < _actorsInConversation.Length
        Actor currentActor = _actorsInConversation[i] as Actor
        if currentActor.GetDisplayName()
            return currentActor
        endIf
        i += 1
    EndWhile
    return none
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    Start new conversation   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function StartConversation(Actor[] actorsToStartConversationWith)
    UpdateActorsArray(actorsToStartConversationWith)

    if(actorsToStartConversationWith.Length < 2)
        Debug.Notification("Not enough characters to start a conversation")
        return
    endIf

    int handle = SKSE_HTTP.createDictionary()
    SKSE_HTTP.setString(handle, GetFullKey(mConsts.KEY_REQUESTTYPE),"start_conversation")
    ;add characters 
    int[] handlesNpcs = BuildNpcsInConversationArray()
    SKSE_HTTP.setNestedDictionariesArray(handle, GetFullKey(mConsts.KEY_ACTORS), handlesNpcs)
    ;add context
    int handleContext = BuildContext()
    SKSE_HTTP.setNestedDictionary(handle, GetFullKey(mConsts.KEY_CONTEXT), handleContext)

    SKSE_HTTP.sendLocalhostHttpRequest(handle, mConsts.HTTP_PORT, mConsts.HTTP_ROUTE_MAIN)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       End conversation      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function EndConversation()
    _actorsInConversation = none
    _localMenuTimer = -1

    int handle = SKSE_HTTP.createDictionary()
    SKSE_HTTP.setString(handle, GetFullKey(mConsts.KEY_REQUESTTYPE),GetFullKey(mConsts.KEY_REQUESTTYPE_ENDCONVERSATION))
    SKSE_HTTP.sendLocalhostHttpRequest(handle, mConsts.HTTP_PORT, mConsts.HTTP_ROUTE_MAIN)
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Handle player speaking    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function sendRequestForPlayerInput(string playerInput)
    int handle = SKSE_HTTP.createDictionary()
    SKSE_HTTP.setString(handle, GetFullKey(mConsts.KEY_REQUESTTYPE), GetFullKey(mConsts.KEY_REQUESTTYPE_PLAYERINPUT))
    SKSE_HTTP.setString(handle, GetFullKey(mConsts.KEY_REQUESTTYPE_PLAYERINPUT), playerinput)
    int[] handlesNpcs = BuildNpcsInConversationArray()
    SKSE_HTTP.setNestedDictionariesArray(handle, GetFullKey(mConsts.KEY_ACTORS), handlesNpcs)    
    int handleContext = BuildContext()
    SKSE_HTTP.setNestedDictionary(handle, GetFullKey(mConsts.KEY_CONTEXT), handleContext)

    ClearIngameEvent()    
    SKSE_HTTP.sendLocalhostHttpRequest(handle, mConsts.HTTP_PORT, mConsts.HTTP_ROUTE_STT)
endFunction

function sendRequestForVoiceTranscribe()
    int handle = SKSE_HTTP.createDictionary()
    SKSE_HTTP.setString(handle, GetFullKey(mConsts.KEY_REQUESTTYPE), GetFullKey(mConsts.KEY_REQUESTTYPE_TTS))
    string[] namesInConversation = Utility.CreateStringArray(_actorsInConversation.Length)
    int i = 0
    While i < _actorsInConversation.Length
        namesInConversation[i] = (_actorsInConversation[i] as Actor).GetDisplayName()
        i += 1
    EndWhile
    SKSE_HTTP.setStringArray(handle, GetFullKey(mConsts.KEY_INPUT_NAMESINCONVERSATION), namesInConversation)
    SKSE_HTTP.sendLocalhostHttpRequest(handle, mConsts.HTTP_PORT, mConsts.HTTP_ROUTE_STT)
endFunction

function StartTimer()
	_localMenuTimer = repository.MantellaEffectResponseTimer
    int localMenuTimerInt = Math.Floor(_localMenuTimer)
	Debug.Notification("Awaiting player input for "+localMenuTimerInt+" seconds")
	String Monitorplayerresponse
	String timerCheckEndConversation
	;Debug.Notification("Timer is "+localMenuTimer)
	While _localMenuTimer >= 0
		;Debug.Notification("Timer is "+localMenuTimer)
		;if at any point the conversation is ended and the actorsInConversation are reset, leave this loop
		if _actorsInConversation.Length < 2 || _localMenuTimer < 0
            _localMenuTimer = -1
			return
		endif
		If _localMenuTimer > 0
			Utility.Wait(1)
			if !utility.IsInMenuMode()
				_localMenuTimer = _localMenuTimer - 1
			endif
			;Debug.Notification("Timer is "+localMenuTimer)
		elseif _localMenuTimer == 0
            while !utility.IsInMenuMode()
				Utility.Wait(1)
			endWhile
            ;Debug.Notification("opening menu now")
            GetPlayerTextInput()
		endIf
	endWhile
endFunction

function GetPlayerTextInput()
    UIExtensions.InitMenu("UITextEntryMenu")
    UIExtensions.OpenMenu("UITextEntryMenu")

    string result = UIExtensions.GetMenuResultString("UITextEntryMenu")
    sendRequestForPlayerInput(result)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        Ingame events        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function AddIngameEvent(string eventText)
    _ingameEvents = Utility.ResizeStringArray(_ingameEvents, _ingameEvents.Length + 1)
    _ingameEvents[_ingameEvents.Length - 1] = eventText
EndFunction

Function ClearIngameEvent()
    _ingameEvents = Utility.CreateStringArray(0)
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;            Utils            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string Function GetFullKey(string dictionaryKey)
    return  mConsts.PREFIX + dictionaryKey
EndFunction

Function UpdateActorsArray(Actor[] actorsToStartConversationWith)
    if(!_actorsInConversation)
        _actorsInConversation = Utility.CreateFormArray(actorsToStartConversationWith.Length)
        While i < actorsToStartConversationWith.Length
            _actorsInConversation[i] = actorsToStartConversationWith[i]
            i += 1
        EndWhile
        return
    endIf
    int i = 0
    While i < actorsToStartConversationWith.Length
        int pos = _actorsInConversation.Find(actorsToStartConversationWith[i])
        if(pos < 0)
            _actorsInConversation = Utility.ResizeFormArray(_actorsInConversation, _actorsInConversation.Length + 1)
            _actorsInConversation[_actorsInConversation.Length - 1] = actorsToStartConversationWith[i]
        endIf
        i += 1
    EndWhile
EndFunction

int Function CountActorsInConversation()
    If (_actorsInConversation)
        return _actorsInConversation.Length
    EndIf
    return 0
EndFunction

Actor Function GetActorInConversationByIndex(int indexOfActor) 
    If (_actorsInConversation && indexOfActor >= 0 && indexOfActor < _actorsInConversation.Length)
        return _actorsInConversation[indexOfActor] as Actor
    EndIf
    return none
EndFunction

int[] function BuildNpcsInConversationArray()
    int[] actorHandles =  Utility.CreateIntArray(_actorsInConversation.Length)
    int i = 0
    While i < _actorsInConversation.Length
        actorHandles[i] = buildActorSetting(_actorsInConversation[i] as Actor)
        i += 1
    EndWhile
    return actorHandles
endFunction

int function buildActorSetting(Actor actorToBuild)    
    int handle = SKSE_HTTP.createDictionary()
    SKSE_HTTP.setString(handle, GetFullKey(mConsts.KEY_ACTOR_NAME), actorToBuild.GetDisplayName())
    SKSE_HTTP.setBool(handle, GetFullKey(mConsts.KEY_ACTOR_ISPLAYER), actorToBuild == game.getplayer())
    SKSE_HTTP.setInt(handle, GetFullKey(mConsts.KEY_ACTOR_GENDER), actorToBuild.getleveledactorbase().getsex())
    SKSE_HTTP.setString(handle, GetFullKey(mConsts.KEY_ACTOR_RACE), actorToBuild.getrace())
    SKSE_HTTP.setInt(handle, GetFullKey(mConsts.KEY_ACTOR_RELATIONSHIPRANK), actorToBuild.getrelationshiprank(game.getplayer()))
    SKSE_HTTP.setString(handle, GetFullKey(mConsts.KEY_ACTOR_VOICETYPE), actorToBuild.GetVoiceType())
    SKSE_HTTP.setBool(handle, GetFullKey(mConsts.KEY_ACTOR_ISENEMY), actorToBuild.getcombattarget() == game.getplayer())    
    return handle
endFunction

int function BuildContext()
    int handle = SKSE_HTTP.createDictionary()
    String currLoc = ((_actorsInConversation[0] as Actor).GetCurrentLocation() as Form).getName()
    if currLoc == ""
        currLoc = "Skyrim"
    endIf
    SKSE_HTTP.setString(handle, GetFullKey(mConsts.KEY_CONTEXT_LOCATION), currLoc)
    SKSE_HTTP.setInt(handle, GetFullKey(mConsts.KEY_CONTEXT_TIME), GetCurrentHourOfDay())
    SKSE_HTTP.setStringArray(handle, GetFullKey(mConsts.KEY_CONTEXT_INGAMEEVENTS), _ingameEvents)
    return handle
endFunction

int function GetCurrentHourOfDay()
	float Time = Utility.GetCurrentGameTime()
	Time -= Math.Floor(Time) ; Remove "previous in-game days passed" bit
	Time *= 24 ; Convert from fraction of a day to number of hours
	int Hour = Math.Floor(Time) ; Get whole hour
	return Hour
endFunction