Scriptname MantellaAdvancedAction_Brawl extends Quest Hidden 

FavorDialogueScript Property DialogueFavorGeneric Auto
Actor Property PlayerRef Auto
MantellaRepository property repository Auto
MantellaConstants property mConsts Auto
MantellaInterface property EventInterface Auto
Faction Property MantellaFunctionSourceFaction Auto

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ACTIONS_PREFIX + mConsts.ACTION_NPC_BRAWL, "OnNpcBrawlActionReceived")
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_BRAWL, "OnNpcBrawlAdvancedActionReceived")
EndEvent

event OnNpcBrawlActionReceived(Form speaker)
    Actor sourceActor = speaker as Actor
    NpcBrawl(sourceActor)
endEvent


event OnNpcBrawlAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)
    MantellaConversation conversation = conversationQuest as MantellaConversation
    
    ; Extract NPC names from parameters
    string[] sourceNames = SKSE_HTTP.getStringArray(argumentsHandle, mConsts.ACTION_ARG_SOURCE)

    ; Resolve each name to an Actor reference
    int i = 0
    While i < sourceNames.Length
        Actor sourceActor = conversation.GetActorByName(sourceNames[i])
        NpcBrawl(sourceActor)
        i += 1
    EndWhile
endEvent


Function NpcBrawl(Actor source)
    if source
        Debug.Notification(source.GetDisplayName() + " wants a fight.")
        source.RemoveFromFaction(MantellaFunctionSourceFaction) ; End other actions if running
        DialogueFavorGeneric.Brawl(source)
    endif
EndFunction