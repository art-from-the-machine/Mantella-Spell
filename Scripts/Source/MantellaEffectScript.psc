Scriptname MantellaEffectScript extends activemagiceffect

Import MantellaConversation
Import SKSE_HTTP

Topic property MantellaDialogueLine auto
ReferenceAlias property TargetRefAlias auto

MantellaRepository property repository auto

event OnEffectStart(Actor target, Actor caster)
    RegisterForModEvent("SKSE_HTTP_OnHttpReplyReceived","OnHttpReplyReceived")
    Utility.Wait(0.5)
    Actor[] actors = new Actor[2]
    actors[0] = caster
    actors[1] = target
    MantellaConversation conversation = Quest.GetQuest("MantellaConversation") as MantellaConversation
    if(!conversation.IsRunning())
        conversation.Start()
        conversation.StartConversation(actors)
    Else
        conversation.AddActorsToConversation(actors)
    endIf
endEvent
