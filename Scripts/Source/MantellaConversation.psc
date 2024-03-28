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
String[] _ingameEvents
String[] _extraRequestActions
bool _does_accept_player_input = false

event OnInit()    
    RegisterForModEvent("SKSE_HTTP_OnHttpReplyReceived","OnHttpReplyReceived")
    RegisterForModEvent("SKSE_HTTP_OnHttpErrorReceived","OnHttpErrorReceived")
    RegisterForModEvent(mConsts.EVENT_ACTIONS + mConsts.ACTION_RELOADCONVERSATION,"OnReloadConversationActionReceived")
    RegisterForModEvent(mConsts.EVENT_ACTIONS + mConsts.ACTION_ENDCONVERSATION,"OnEndConversationActionReceived")
endEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    Start new conversation   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function StartConversation(Actor[] actorsToStartConversationWith)
    if(actorsToStartConversationWith.Length > 2)
        Debug.Notification("Can not start conversation. Conversation is already running.")
        return
    endIf
    
    UpdateActorsArray(actorsToStartConversationWith)

    if(actorsToStartConversationWith.Length < 2)
        Debug.Notification("Not enough characters to start a conversation")
        return
    endIf    
   
    int handle = SKSE_HTTP.createDictionary()
    SKSE_HTTP.setString(handle, mConsts.KEY_REQUESTTYPE, mConsts.KEY_REQUESTTYPE_STARTCONVERSATION)
    AddCurrentActorsAndContext(handle)
    SKSE_HTTP.sendLocalhostHttpRequest(handle, repository.HttpPort, mConsts.HTTP_ROUTE_MAIN)
    ; string address = "http://localhost:" + mConsts.HTTP_PORT + "/" + mConsts.HTTP_ROUTE_MAIN
    ; Debug.Notification("Sent StartConversation http request to " + address)  
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    Continue conversation    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function AddActorsToConversation(Actor[] actorsToAdd)
    UpdateActorsArray(actorsToAdd)    
EndFunction

event OnHttpReplyReceived(int typedDictionaryHandle)
    string replyType = SKSE_HTTP.getString(typedDictionaryHandle, mConsts.KEY_REPLYTYPE ,"error")
    If (replyType != "error")
        ContinueConversation(typedDictionaryHandle)        
    Else
        string errorMessage = SKSE_HTTP.getString(typedDictionaryHandle, "mantella_message","Error: Could not retrieve error message")
        Debug.Notification(errorMessage)
        CleanupConversation()
    EndIf
endEvent

function ContinueConversation(int handle)
    string nextAction = SKSE_HTTP.getString(handle, mConsts.KEY_REPLYTYPE, "Error: Did not receive reply type")
    ; Debug.Notification(nextAction)
    if(nextAction == mConsts.KEY_REPLYTTYPE_STARTCONVERSATIONCOMPLETED)
        RequestContinueConversation()
    elseIf(nextAction == mConsts.KEY_REPLYTYPE_NPCTALK)
        int npcTalkHandle = SKSE_HTTP.getNestedDictionary(handle, mConsts.KEY_REPLYTYPE_NPCTALK)
        ProcessNpcSpeak(npcTalkHandle)
        RequestContinueConversation()
    elseIf(nextAction == mConsts.KEY_REPLYTYPE_PLAYERTALK)
        If (repository.microphoneEnabled)
            sendRequestForVoiceTranscribe()
        Else
            Debug.Notification("Awaiting player text input...")
            _does_accept_player_input = True
        EndIf
    elseIf (nextAction == mConsts.KEY_REQUESTTYPE_TTS)
        string transcribe = SKSE_HTTP.getString(handle, mConsts.KEY_TRANSCRIBE, "*Complete gibberish*")
        sendRequestForPlayerInput(transcribe)
    elseIf(nextAction == mConsts.KEY_REPLYTYPE_ENDCONVERSATION)
        CleanupConversation()
    endIf
endFunction

function RequestContinueConversation()
    int handle = SKSE_HTTP.createDictionary()
    SKSE_HTTP.setString(handle, mConsts.KEY_REQUESTTYPE, mConsts.KEY_REQUESTTYPE_CONTINUECONVERSATION)
    AddCurrentActorsAndContext(handle)
    if(_extraRequestActions && _extraRequestActions.Length > 0)
        Debug.Notification("_extraRequestActions contains items. Sending them along with continue!")
        SKSE_HTTP.setStringArray(handle, mConsts.KEY_REQUEST_EXTRA_ACTIONS, _extraRequestActions)
        ClearExtraRequestAction()
        Debug.Notification("_extraRequestActions got cleared. Remaining items: " + _extraRequestActions.Length)
    endif
    SKSE_HTTP.sendLocalhostHttpRequest(handle, repository.HttpPort, mConsts.HTTP_ROUTE_MAIN)
endFunction

function ProcessNpcSpeak(int handle)
    string speakerName = SKSE_HTTP.getString(handle, mConsts.KEY_ACTOR_SPEAKER, "Error: No speaker transmitted for action 'NPC talk'")
    ;Debug.Notification("Transmitted speaker name: "+ speakerName)
    Actor speaker = GetActorInConversation(speakerName)
    ;Debug.Notification("Chosen Actor: "+ speaker.GetDisplayName())
    if speaker != none
        string lineToSpeak = SKSE_HTTP.getString(handle, mConsts.KEY_ACTOR_LINETOSPEAK, "Error: No line transmitted for actor to speak")
        float duration = SKSE_HTTP.getFloat(handle, mConsts.KEY_ACTOR_DURATION, 0)
        string[] actions = SKSE_HTTP.getStringArray(handle, mConsts.KEY_ACTOR_ACTIONS)        
        RaiseActionEvent(speaker, lineToSpeak, actions)
        NpcSpeak(speaker, lineToSpeak, Game.GetPlayer(), duration)
    endIf
endFunction

function NpcSpeak(Actor actorSpeaking, string lineToSay, Actor actorToSpekTo, float duration)
    MantellaSubtitles.SetInjectTopicAndSubtitleForSpeaker(actorSpeaking, MantellaDialogueLine, lineToSay)
    actorSpeaking.Say(MantellaDialogueLine, abSpeakInPlayersHead=false)
    actorSpeaking.SetLookAt(actorToSpekTo)
    float durationAdjusted = duration - 0.5
    if(durationAdjusted < 0)
        durationAdjusted = 0
    endIf
    Utility.Wait(durationAdjusted)
endfunction

Actor function GetActorInConversation(string actorName)
    int i = 0
    While i < _actorsInConversation.Length
        Actor currentActor = _actorsInConversation[i] as Actor
        if currentActor.GetDisplayName() == actorName
            return currentActor
        endIf
        i += 1
    EndWhile
    return none
endFunction



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       End conversation      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

event OnEndConversationActionReceived(Form speaker, string sentence)
    EndConversation()
endEvent

Function EndConversation()
    int handle = SKSE_HTTP.createDictionary()
    SKSE_HTTP.setString(handle, mConsts.KEY_REQUESTTYPE,mConsts.KEY_REQUESTTYPE_ENDCONVERSATION)
    SKSE_HTTP.sendLocalhostHttpRequest(handle, repository.HttpPort, mConsts.HTTP_ROUTE_MAIN)
EndFunction

Function CleanupConversation()
    _actorsInConversation = None
    _ingameEvents = None
    _does_accept_player_input = false
    SKSE_HTTP.clearAllDictionaries()
    Debug.Notification("Conversation has ended!")  
    Stop()
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Handle player speaking    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function sendRequestForPlayerInput(string playerInput)
    int handle = SKSE_HTTP.createDictionary()
    SKSE_HTTP.setString(handle, mConsts.KEY_REQUESTTYPE, mConsts.KEY_REQUESTTYPE_PLAYERINPUT)
    SKSE_HTTP.setString(handle, mConsts.KEY_REQUESTTYPE_PLAYERINPUT, playerinput)
    int[] handlesNpcs = BuildNpcsInConversationArray()
    SKSE_HTTP.setNestedDictionariesArray(handle, mConsts.KEY_ACTORS, handlesNpcs)    
    int handleContext = BuildContext()
    SKSE_HTTP.setNestedDictionary(handle, mConsts.KEY_CONTEXT, handleContext)

    ClearIngameEvent()    
    SKSE_HTTP.sendLocalhostHttpRequest(handle, repository.HttpPort, mConsts.HTTP_ROUTE_MAIN)
endFunction

function sendRequestForVoiceTranscribe()
    int handle = SKSE_HTTP.createDictionary()
    SKSE_HTTP.setString(handle, mConsts.KEY_REQUESTTYPE, mConsts.KEY_REQUESTTYPE_TTS)
    string[] namesInConversation = Utility.CreateStringArray(_actorsInConversation.Length)
    int i = 0
    While i < _actorsInConversation.Length
        namesInConversation[i] = (_actorsInConversation[i] as Actor).GetDisplayName()
        i += 1
    EndWhile
    SKSE_HTTP.setStringArray(handle, mConsts.KEY_INPUT_NAMESINCONVERSATION, namesInConversation)
    SKSE_HTTP.sendLocalhostHttpRequest(handle, repository.HttpPort, mConsts.HTTP_ROUTE_STT)
endFunction

function GetPlayerTextInput()
    if(!_does_accept_player_input)
        return
    endif

    UIExtensions.InitMenu("UITextEntryMenu")
    UIExtensions.OpenMenu("UITextEntryMenu")

    string result = UIExtensions.GetMenuResultString("UITextEntryMenu")
    if (result && result != "")
        sendRequestForPlayerInput(result)
        _does_accept_player_input = False
    endIf
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       Action handler        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function RaiseActionEvent(Actor speaker, string lineToSpeak, string[] actions)
    if(!actions || actions.Length == 0)
        return ;dont send out an action event if there are no actions to act upon
    endIf

    int i = 0
    While i < actions.Length
        string extraAction = actions[i]
        Debug.Notification("Recieved action " + extraAction + ". Sending out event!")
        int handle = ModEvent.Create(mConsts.EVENT_ACTIONS + extraAction)
        if (handle)
            ModEvent.PushForm(handle, speaker)
            ModEvent.PushString(handle, lineToSpeak)
            ModEvent.Send(handle)
        endIf 
        i += 1
    EndWhile
    
EndFunction

Function AddExtraRequestAction(string extraAction)
    if(!_extraRequestActions)
        _extraRequestActions = Utility.CreateStringArray(1)
    Else
        _extraRequestActions = Utility.ResizeStringArray(_extraRequestActions, _extraRequestActions.Length + 1)
    endif
    _extraRequestActions[_extraRequestActions.Length - 1] = extraAction
EndFunction

Function ClearExtraRequestAction()
    _extraRequestActions = Utility.CreateStringArray(0)
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        Ingame events        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function AddIngameEvent(string eventText)
    if(!_ingameEvents)
        _ingameEvents = Utility.CreateStringArray(1)
    Else
        _ingameEvents = Utility.ResizeStringArray(_ingameEvents, _ingameEvents.Length + 1)
    endif
    _ingameEvents[_extraRequestActions.Length - 1] = eventText
EndFunction

Function ClearIngameEvent()
    _ingameEvents = Utility.CreateStringArray(0)
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Action: Reload conversation ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

event OnReloadConversationActionReceived(Form speaker, string sentence)
    Debug.Notification("OnReloadConversationActionReceived triggered")
    AddExtraRequestAction(mConsts.ACTION_RELOADCONVERSATION)
endEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       Error handling        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

event OnHttpErrorReceived(int typedDictionaryHandle)
    string errorMessage = SKSE_HTTP.getString(typedDictionaryHandle, mConsts.HTTP_ERROR ,"error")
    If (errorMessage != "error")
        Debug.Notification("Received SKSE_HTTP error: " + errorMessage)        
        CleanupConversation()
    Else
        Debug.Notification("Error: Could not retrieve error")
        CleanupConversation()
    EndIf
endEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;            Utils            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bool Function IsPlayerInConversation()
    if(!_actorsInConversation)
        return false
    endif
        int i = 0
        While i < _actorsInConversation.Length
            if (_actorsInConversation[i] == Game.GetPlayer())
                return true
            endif
            i += 1
        EndWhile
        return false    
EndFunction

Function UpdateActorsArray(Actor[] actorsToStartConversationWith)
    int i = 0
    if(!_actorsInConversation)
        _actorsInConversation = Utility.CreateFormArray(actorsToStartConversationWith.Length)
        While i < actorsToStartConversationWith.Length
            _actorsInConversation[i] = actorsToStartConversationWith[i]
            i += 1
        EndWhile
        return
    endIf
    i = 0
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

Function AddCurrentActorsAndContext(int handleToAddTo)
    ;Add Actors
    int[] handlesNpcs = BuildNpcsInConversationArray()
    SKSE_HTTP.setNestedDictionariesArray(handleToAddTo, mConsts.KEY_ACTORS, handlesNpcs)
    ;add context
    int handleContext = BuildContext()
    SKSE_HTTP.setNestedDictionary(handleToAddTo, mConsts.KEY_CONTEXT, handleContext)
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
    SKSE_HTTP.setInt(handle, mConsts.KEY_ACTOR_ID, (actorToBuild.getactorbase() as form).getformid())
    SKSE_HTTP.setString(handle, mConsts.KEY_ACTOR_NAME, actorToBuild.GetDisplayName())
    SKSE_HTTP.setBool(handle, mConsts.KEY_ACTOR_ISPLAYER, actorToBuild == game.getplayer())
    SKSE_HTTP.setInt(handle, mConsts.KEY_ACTOR_GENDER, actorToBuild.getleveledactorbase().getsex())
    SKSE_HTTP.setString(handle, mConsts.KEY_ACTOR_RACE, actorToBuild.getrace())
    SKSE_HTTP.setInt(handle, mConsts.KEY_ACTOR_RELATIONSHIPRANK, actorToBuild.getrelationshiprank(game.getplayer()))
    SKSE_HTTP.setString(handle, mConsts.KEY_ACTOR_VOICETYPE, actorToBuild.GetVoiceType())
    SKSE_HTTP.setBool(handle, mConsts.KEY_ACTOR_ISINCOMBAT, actorToBuild.IsInCombat())    
    SKSE_HTTP.setBool(handle, mConsts.KEY_ACTOR_ISENEMY, actorToBuild.getcombattarget() == game.getplayer())    
    return handle
endFunction

int function BuildContext()
    int handle = SKSE_HTTP.createDictionary()
    String currLoc = ((_actorsInConversation[0] as Actor).GetCurrentLocation() as Form).getName()
    if currLoc == ""
        currLoc = "Skyrim"
    endIf
    SKSE_HTTP.setString(handle, mConsts.KEY_CONTEXT_LOCATION, currLoc)
    SKSE_HTTP.setInt(handle, mConsts.KEY_CONTEXT_TIME, GetCurrentHourOfDay())
    SKSE_HTTP.setStringArray(handle, mConsts.KEY_CONTEXT_INGAMEEVENTS, _ingameEvents)
    return handle
endFunction

int function GetCurrentHourOfDay()
	float Time = Utility.GetCurrentGameTime()
	Time -= Math.Floor(Time) ; Remove "previous in-game days passed" bit
	Time *= 24 ; Convert from fraction of a day to number of hours
	int Hour = Math.Floor(Time) ; Get whole hour
	return Hour
endFunction