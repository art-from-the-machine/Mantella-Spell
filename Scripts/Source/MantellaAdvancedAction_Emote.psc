Scriptname MantellaAdvancedAction_Emote extends Quest Hidden 

MantellaInterface Property EventInterface Auto
MantellaConstants Property mConsts Auto
Topic Property MantellaLaugh Auto
GlobalVariable Property MantellaVoiceID Auto

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_EMOTE, "OnNpcEmoteAdvancedActionReceived")
EndEvent

event OnNpcEmoteAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)
    MantellaConversation conversation = conversationQuest as MantellaConversation
    
    ; Extract parameters
    string[] sourceNames = SKSE_HTTP.getStringArray(argumentsHandle, mConsts.ACTION_ARG_SOURCE)
    int emoteID = SKSE_HTTP.getInt(argumentsHandle, "emote_name_id")

    Idle emote = Game.GetFormFromFile(emoteID, "Skyrim.esm") as Idle

    if emote
        int i = 0
        While i < sourceNames.Length
            Actor sourceActor = conversation.GetActorByName(sourceNames[i])
            if sourceActor
                if emoteID == 482399 ; IdleLaugh
                    PlayLaughterSound(sourceActor, conversation)
                else
                    sourceActor.PlayIdle(emote)
                endIf
            endif
            i += 1
        EndWhile
    endif
endEvent


Function PlayLaughterSound(Actor speaker, MantellaConversation conversation)
    ; Play laughter sound (the voiceline already plays IdleLaugh when the voiceline is played)

    ; Take note of the original voice in order to select appropriate laugh sounds
    VoiceType orgVoice = SKSE_HTTP.GetVoiceType(speaker)
    MantellaVoiceID.SetValueInt(orgVoice.GetFormID())

    SKSE_HTTP.SetVoiceType(speaker, conversation.MantellaVoice00)

    speaker.Say(MantellaLaugh, abSpeakInPlayersHead=False)
    speaker.AddSpell(conversation.MantellaIsTalkingSpell, False)

    ; Restore original voice type
    SKSE_HTTP.SetVoiceType(speaker, orgVoice)
EndFunction