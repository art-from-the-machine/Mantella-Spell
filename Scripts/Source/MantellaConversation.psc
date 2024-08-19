Scriptname MantellaConversation extends Quest hidden

Import SKSE_HTTP
Import Utility

Topic property MantellaDialogueLine auto
MantellaRepository property repository auto
MantellaConstants property mConsts auto
Faction Property MantellaConversationParticipantsFaction Auto
FormList Property Participants auto
Quest Property MantellaConversationParticipantsQuest auto
SPELL Property MantellaIsTalkingSpell Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;           Globals           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String[] _ingameEvents
String[] _extraRequestActions
bool _does_accept_player_input = false
bool _isTalking = false
bool _hasPendingVisionGeneration = false
string _PlayerTextInput
Actor _lastNpcToSpeak = None

event OnInit()    
    RegisterForModEvent("SKSE_HTTP_OnHttpReplyReceived","OnHttpReplyReceived")
    RegisterForModEvent("SKSE_HTTP_OnHttpErrorReceived","OnHttpErrorReceived")
    RegisterForModEvent(mConsts.EVENT_ACTIONS + mConsts.ACTION_RELOADCONVERSATION,"OnReloadConversationActionReceived")
    RegisterForModEvent(mConsts.EVENT_ACTIONS + mConsts.ACTION_ENDCONVERSATION,"OnEndConversationActionReceived")
    RegisterForModEvent(mConsts.EVENT_ACTIONS + mConsts.ACTION_REMOVECHARACTER,"OnRemoveCharacterActionReceived")
endEvent

event OnPlayerLoadGame()
    EndConversation()
    CleanupConversation()
endEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    Start new conversation   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function StartConversation(Actor[] actorsToStartConversationWith)
    if(actorsToStartConversationWith.Length > 2)
        Debug.Notification("Cannot start conversation. Conversation is already running.")
        return
    endIf
    
    AddActors(actorsToStartConversationWith)

    if(actorsToStartConversationWith.Length < 2)
        Debug.Notification("Not enough characters to start a conversation.")
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
    AddActors(actorsToAdd)    
EndFunction

Function RemoveActorsFromConversation(Actor[] actorsToRemove)
    RemoveActors(actorsToRemove)  
EndFunction

Function SetIsTalking(bool isTalking)
    _isTalking = isTalking
EndFunction

bool Function GetIsTalking()
    return _isTalking
EndFunction

event OnHttpReplyReceived(int typedDictionaryHandle)
    string replyType = SKSE_HTTP.getString(typedDictionaryHandle, mConsts.KEY_REPLYTYPE ,"error")
    If (replyType != "error")
        ContinueConversation(typedDictionaryHandle)        
    Else
        string errorMessage = SKSE_HTTP.getString(typedDictionaryHandle, "mantella_message","Error: Could not retrieve error message")
        ;Debug.Notification(errorMessage)
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
        if repository.allowVision
            MantellaVisionScript.GenerateMantellaVision(repository)
        endif
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
        WaitForNpcToFinishSpeaking(speaker, _lastNpcToSpeak)
        string lineToSpeak = SKSE_HTTP.getString(handle, mConsts.KEY_ACTOR_LINETOSPEAK, "Error: No line transmitted for actor to speak")
        float duration = SKSE_HTTP.getFloat(handle, mConsts.KEY_ACTOR_DURATION, 0)
        string[] actions = SKSE_HTTP.getStringArray(handle, mConsts.KEY_ACTOR_ACTIONS)        
        RaiseActionEvent(speaker, lineToSpeak, actions)
        Actor NpcToLookAt = GetNpcToLookAt(speaker, _lastNpcToSpeak)
        NpcSpeak(speaker, lineToSpeak, NpcToLookAt, duration)
        _lastNpcToSpeak = speaker
    endIf
endFunction

function NpcSpeak(Actor actorSpeaking, string lineToSay, Actor actorToSpeakTo, float duration)
    MantellaSubtitles.SetInjectTopicAndSubtitleForSpeaker(actorSpeaking, MantellaDialogueLine, lineToSay)
    actorSpeaking.Say(MantellaDialogueLine, abSpeakInPlayersHead=false)
    actorSpeaking.SetLookAt(actorToSpeakTo)
    actorToSpeakTo.SetLookAt(actorSpeaking)
    float durationAdjusted = duration - 1.0
    if(durationAdjusted < 0)
        durationAdjusted = 0
    endIf
    Utility.Wait(durationAdjusted)
endfunction

string function GetActorName(actor actorToGetName)
    string actorName = actorToGetName.GetDisplayName()
    int actorID = actorToGetName.GetFactionRank(MantellaConversationParticipantsFaction)
    if actorID > 0
        actorName = actorName + " " + actorID
    endIf
    return actorName
endFunction

Actor function GetActorInConversation(string actorName)
    int i = 0
    While i < Participants.GetSize()
        Actor currentActor = Participants.GetAt(i) as Actor
        if GetActorName(currentActor) == actorName
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
    int i = 0
    ClearParticipants()
    _ingameEvents = None
    _does_accept_player_input = false
    _isTalking = false
    _lastNpcToSpeak = None
    ;SKSE_HTTP.clearAllDictionaries()
    If (MantellaConversationParticipantsQuest.IsRunning())
        MantellaConversationParticipantsQuest.Stop()
    EndIf
    Debug.Notification("Conversation ended.")  
    Stop()
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;      Remove character       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

event OnRemoveCharacterActionReceived(Form speaker, string sentence)
    Actor[] actors = new Actor[2]
    actors[0] = speaker as Actor
    RemoveActors(actors)
endEvent

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

    SKSE_HTTP.sendLocalhostHttpRequest(handle, repository.HttpPort, mConsts.HTTP_ROUTE_MAIN)
endFunction

function sendRequestForVoiceTranscribe()
    int handle = SKSE_HTTP.createDictionary()
    SKSE_HTTP.setString(handle, mConsts.KEY_REQUESTTYPE, mConsts.KEY_REQUESTTYPE_TTS)
    string[] namesInConversation = Utility.CreateStringArray(Participants.GetSize())
    int i = 0
    While i < Participants.GetSize()
        namesInConversation[i] = (Participants.GetAt(i) as Actor).GetDisplayName()
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
        _PlayerTextInput=result
        if repository.allowVision
            _hasPendingVisionGeneration=true
            RegisterForSingleUpdate(0.3);Spacing out the GenerateMantellaVision() to avoid taking a screenshot of the interface
        else
            sendRequestForPlayerInput(_PlayerTextInput)
            _does_accept_player_input = False
            Debug.Notification("Thinking...")
        endif
    endIf
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;     Event OnUpdate management (timer mangement)          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Event OnUpdate()
    ;Spacing out the GenerateMantellaVision() to avoid taking a screenshot of the interface
    if _hasPendingVisionGeneration==true ;checking if the OnUpdate call is coming from a pending vision generation request
        if repository.allowVision
            MantellaVisionScript.GenerateMantellaVision(repository)
            _hasPendingVisionGeneration=false
        endif
        sendRequestForPlayerInput(_PlayerTextInput)
        _does_accept_player_input = False
        Debug.Notification("Thinking...")
    endif
endEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;     Handle NPC speaking     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Actor function GetNpcToLookAt(Actor speaker, Actor lastNpcToSpeak)
    Actor NpcToLookAt = None
    if (lastNpcToSpeak != speaker)
        if (lastNpcToSpeak != None)
            NpcToLookAt = lastNpcToSpeak
        else
            int i = 0
            while i < CountActorsInConversation()
                Actor tmpActor = GetActorInConversationByIndex(i)
                if GetActorName(tmpActor) != GetActorName(speaker)
                    NpcToLookAt = tmpActor
                endIf
                i += 1
            endWhile
            if IsPlayerInConversation()
                NpcToLookAt = Game.GetPlayer()
            endIf
        endIf
    elseIf IsPlayerInConversation()
        NpcToLookAt = Game.GetPlayer()
    endIf
    return NpcToLookAt
endFunction

function WaitForNpcToFinishSpeaking(Actor speaker, Actor lastNpcToSpeak)
    if lastNpcToSpeak != None
        speaker.AddSpell(MantellaIsTalkingSpell)
    endIf
    Utility.Wait(0.01)
    ;Debug.Notification("Chosen Actor: "+ speaker.GetDisplayName())
    bool waitingToSpeakMessage = true
    float waitTime = 0.01
    float totalWaitTime = 0
    while _isTalking == true
        if waitingToSpeakMessage == true
            ;Debug.Notification("Waiting for NPC to finish speaking before next line...")
            waitingToSpeakMessage = false
        endIf
        Utility.Wait(waitTime)
        totalWaitTime += waitTime
        if totalWaitTime > 20
            Debug.Notification("NPC speaking too long, ending wait...")
            _isTalking = false
        endIf
    endWhile
    if lastNpcToSpeak != None
        speaker.RemoveSpell(MantellaIsTalkingSpell)
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
        ;Debug.Notification("Recieved action " + extraAction + ". Sending out event!")
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
    _ingameEvents[_ingameEvents.Length - 1] = eventText
EndFunction

Function ClearIngameEvent()
    _ingameEvents = Utility.CreateStringArray(0)
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Action: Reload conversation ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

event OnReloadConversationActionReceived(Form speaker, string sentence)
    ;Debug.Notification("OnReloadConversationActionReceived triggered")
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
        ;Debug.Notification("Error: Could not retrieve error")
        CleanupConversation()
    EndIf
endEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;            Access           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;            Utils            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bool Function IsPlayerInConversation()
    int i = 0
    While i < Participants.GetSize()
        if (Participants.GetAt(i) == Game.GetPlayer())
            return true
        endif
        i += 1
    EndWhile
    return false    
EndFunction

Function CauseReassignmentOfParticipantAlias()
    If (MantellaConversationParticipantsQuest.IsRunning())
        ;Debug.Notification("Stopping MantellaConversationParticipantsQuest")
        MantellaConversationParticipantsQuest.Stop()
    EndIf
    ;Debug.Notification("Starting MantellaConversationParticipantsQuest to asign QuestAlias")
    MantellaConversationParticipantsQuest.Start()
EndFunction

Function AddActors(Actor[] actorsToAdd)
    int i = 0
    bool wasNewActorAdded = false
    While i < actorsToAdd.Length
        int pos = Participants.Find(actorsToAdd[i])
        if(pos < 0)
            Participants.AddForm(actorsToAdd[i])
            actorsToAdd[i].AddToFaction(MantellaConversationParticipantsFaction)
            wasNewActorAdded = true

            ; check if there are multiple actors with the same name
            int nameCount = 0
            int j = 0
            bool break = false
            if (actorsToAdd[i] != game.getplayer()) ; ignore the player having the same name as an actor
                While (j < Participants.GetSize()) && (break==false)
                    Actor currentActor = Participants.GetAt(j) as Actor
                    if (currentActor.GetDisplayName() == actorsToAdd[i].GetDisplayName())
                        nameCount += 1
                        if (currentActor == actorsToAdd[i]) ; stop counting when the exact actor is found (not just the same name)
                            break = true
                        endIf
                    endIf
                    j += 1
                EndWhile

                if (nameCount > 1)
                    ; set an ID to this non-uniquely-named actor in the form of a faction rank
                    ; these uniquely ID'd names can be called via the GetActorName() function
                    actorsToAdd[i].SetFactionRank(MantellaConversationParticipantsFaction, nameCount)
                endIf
            endIf
        endIf
        i += 1
    EndWhile
    If (wasNewActorAdded)
        CauseReassignmentOfParticipantAlias()
    EndIf
    
    ;PrintActorsInConversation()
EndFunction

Function RemoveActors(Actor[] actorsToRemove)
    PrintActorsArray("Actors to remove: ",actorsToRemove)
    bool wasActorRemoved = false
    int i = 0
    While (i < actorsToRemove.Length)
        If (Participants.HasForm(actorsToRemove[i]))
            Participants.RemoveAddedForm(actorsToRemove[i])
            actorsToRemove[i].RemoveFromFaction(MantellaConversationParticipantsFaction)
            wasActorRemoved = true
        EndIf
        i += 1
    EndWhile
    if (Participants.GetSize() < 2)
        EndConversation()
    ElseIf (wasActorRemoved)
        CauseReassignmentOfParticipantAlias()
    endIf
    ;PrintActorsInConversation()
EndFunction

Function ClearParticipants()
    int i = 0
    While i < Participants.GetSize()
        (Participants.GetAt(i) as Actor).RemoveFromFaction(MantellaConversationParticipantsFaction)
        i += 1
    EndWhile
    Participants.Revert()
EndFunction

bool Function ContainsActor(Actor[] arrayToCheck, Actor actorCheckFor)
    int i = 0
    While i < arrayToCheck.Length
        If (arrayToCheck[i] == actorCheckFor)
            return True
        EndIf
        i += 1
    EndWhile
    return False
EndFunction

Function PrintActorsArray(string prefix, Actor[] actors)
    int i = 0
    string actor_message = ""
    While i < actors.Length
        actor_message += GetActorName(actors[i]) + ", "
        i += 1
    EndWhile
    ;Debug.Notification(prefix + actor_message)
EndFunction

Function PrintActorsInConversation()
    int i = 0
    string actor_message = ""
    While i < Participants.GetSize()
        actor_message += GetActorName(Participants.GetAt(i) as Actor) + ", "
        i += 1
    EndWhile
    Debug.Notification(actor_message)
EndFunction

int Function CountActorsInConversation()
    return Participants.GetSize()
EndFunction

Actor Function GetActorInConversationByIndex(int indexOfActor) 
    If (indexOfActor >= 0 && indexOfActor < Participants.getSize())
        return Participants.GetAt(indexOfActor) as Actor
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
    int[] actorHandles =  Utility.CreateIntArray(Participants.GetSize())
    int i = 0
    While i < Participants.GetSize()
        actorHandles[i] = buildActorSetting(Participants.GetAt(i) as Actor)
        i += 1
    EndWhile
    return actorHandles
endFunction

int function buildActorSetting(Actor actorToBuild)    
    int handle = SKSE_HTTP.createDictionary()
    SKSE_HTTP.setInt(handle, mConsts.KEY_ACTOR_ID, (actorToBuild.getactorbase() as form).getformid())
    SKSE_HTTP.setString(handle, mConsts.KEY_ACTOR_NAME, GetActorName(actorToBuild))
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
    String currLoc = ((Participants.GetAt(0) as Actor).GetCurrentLocation() as Form).getName()
    if currLoc == ""
        currLoc = "Skyrim"
    endIf
    SKSE_HTTP.setString(handle, mConsts.KEY_CONTEXT_LOCATION, currLoc)
    SKSE_HTTP.setInt(handle, mConsts.KEY_CONTEXT_TIME, GetCurrentHourOfDay())
    string[] past_events = deepcopy(_ingameEvents)
    SKSE_HTTP.setStringArray(handle, mConsts.KEY_CONTEXT_INGAMEEVENTS, past_events)
    ClearIngameEvent()
    ;new lines below for custom vision values
    int customValuesHandle = BuildCustomContextValues()
    SKSE_HTTP.setNestedDictionary(handle, mConsts.KEY_CONTEXT_CUSTOMVALUES, customValuesHandle)
    return handle
endFunction

int Function BuildCustomContextValues()
    ;new custom context values that pertains to vision related variables that Mantella Software will use
    int handleCustomContextValues = SKSE_HTTP.createDictionary()
    bool isVisionReady = MantellaVisionScript.checkAndUpdateVisionPipeline(repository) ;Checks if there's a screenshot waiting to be analyzed or if the option to send screenshot to the LLM is enabled
    if isVisionReady
        SKSE_HTTP.setBool(handleCustomContextValues, mConsts.KEY_CONTEXT_CUSTOMVALUES_VISION_READY, isVisionReady)
        SKSE_HTTP.setString(handleCustomContextValues, mConsts.KEY_CONTEXT_CUSTOMVALUES_VISION_RES, repository.visionResolution)
        SKSE_HTTP.setInt(handleCustomContextValues, mConsts.KEY_CONTEXT_CUSTOMVALUES_VISION_RESIZE, repository.visionResize)
        SKSE_HTTP.setBool(handleCustomContextValues, mConsts.KEY_CONTEXT_CUSTOMVALUES_VISION_ISUSINGSTEAMSCREENSHOT, repository.isUsingSteamScreenshot) ;IMPORTANT TO FINISH ADD A CHECK IF USING STEAM SCREENSHOT
        if repository.isUsingSteamScreenshot
            SKSE_HTTP.setInt(handleCustomContextValues, mConsts.KEY_CONTEXT_CUSTOMVALUES_VISION_STEAMSCREENSHOTDELAY, repository.steamScreenshotDelay)
        endif
        BuildVisionHintsValues(handleCustomContextValues)
    endif
    return handleCustomContextValues
EndFunction

int Function BuildVisionHintsValues(int handleCustomContextValues)
    ;new custom context values that pertains to vision related variables that Mantella Software will use
    if repository.allowVisionHints && repository.ActorsInCellArray!="" && repository.currentSKversion != "1.4.15.0"
        SKSE_HTTP.setString(handleCustomContextValues, mConsts.KEY_CONTEXT_CUSTOMVALUES_VISION_HINTSNAMEARRAY, repository.ActorsInCellArray)
        SKSE_HTTP.setString(handleCustomContextValues, mConsts.KEY_CONTEXT_CUSTOMVALUES_VISION_HINTSDISTANCEARRAY, repository.VisionDistanceArray)
        MantellaVisionScript.resetVisionHintsArrays(repository)
    elseif repository.allowVisionHints && repository.currentSKversion == "1.4.15.0" ;basically checking for Skyrim VR
        MantellaVisionScript.ScanCellForActors(repository, true, true) ;trying to scan for NPC names right before sending the player response to the LLM
        if repository.ActorsInCellArray!="" 
            SKSE_HTTP.setString(handleCustomContextValues, mConsts.KEY_CONTEXT_CUSTOMVALUES_VISION_HINTSNAMEARRAY, repository.ActorsInCellArray)
            SKSE_HTTP.setString(handleCustomContextValues, mConsts.KEY_CONTEXT_CUSTOMVALUES_VISION_HINTSDISTANCEARRAY, repository.VisionDistanceArray)
            MantellaVisionScript.resetVisionHintsArrays(repository)
        endif
    endif
EndFunction

int function GetCurrentHourOfDay()
	float Time = Utility.GetCurrentGameTime()
	Time -= Math.Floor(Time) ; Remove "previous in-game days passed" bit
	Time *= 24 ; Convert from fraction of a day to number of hours
	int Hour = Math.Floor(Time) ; Get whole hour
	return Hour
endFunction

string[] function deepcopy(string[] array_to_copy)
    string[] result = Utility.CreateStringArray(array_to_copy.Length)
    int i = 0
    While i < array_to_copy.Length
        result[i] = array_to_copy[i]
        i += 1
    EndWhile
    return result
endFunction