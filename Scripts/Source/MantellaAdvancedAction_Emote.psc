Scriptname MantellaAdvancedAction_Emote extends Quest Hidden 

MantellaInterface Property EventInterface Auto
MantellaConstants Property mConsts Auto

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_EMOTE, "OnNpcEmoteAdvancedActionReceived")
EndEvent

event OnNpcEmoteAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)
    MantellaConversation conversation = conversationQuest as MantellaConversation
    
    ; Extract parameters
    string[] sourceNames = SKSE_HTTP.getStringArray(argumentsHandle, mConsts.ACTION_ARG_SOURCE)
    int emoteID = SKSE_HTTP.getInt(argumentsHandle, "emote_name")

    Idle emote = Game.GetFormFromFile(emoteID, "Skyrim.esm") as Idle

    if emote
        int i = 0
        While i < sourceNames.Length
            Actor sourceActor = conversation.GetActorByName(sourceNames[i])
            if sourceActor
                sourceActor.PlayIdle(emote)
            endif
            i += 1
        EndWhile
    endif
endEvent