Scriptname MantellaEffectScript extends activemagiceffect

Import MantellaConversation
Import SKSE_HTTP

Topic property MantellaDialogueLine auto
ReferenceAlias property TargetRefAlias auto

MantellaRepository property repository auto

event OnEffectStart(Actor target, Actor caster)
	Utility.Wait(0.5)

    RegisterForModEvent("SKSE_HTTP_OnHttpReplyReceived","OnHttpReplyReceived")

    ; String actorName = target.getdisplayname()
    ; String casterName = caster.getdisplayname()

    ; target.addtofaction(repository.giafac_Mantella);gia


    ; if (caster == game.getplayer()) && actorCount == 1
    ;     Debug.Notification("Starting conversation with " + actorName)
    ; elseIf (caster == game.getplayer()) && actorCount >1
    ;         Debug.Notification("Adding " + actorName + " to conversation")
    ; elseIf actorCount == 1
    ;     Debug.Notification("Starting radiant dialogue with " + actorName + " and " + casterName)
    ; endIf
   
    ; Wait for first voiceline to play to avoid old conversation playing
    Utility.Wait(0.5)
    Actor[] actors = new Actor[2]
    actors[0] = caster
    actors[1] = target
    MantellaConversation conversation = Quest.GetQuest("MantellaConversation") as MantellaConversation
    if(!conversation.IsRunning())
        conversation.Start()
    endIf
    conversation.StartConversation(actors)
    
    ; target.removefromfaction(repository.giafac_Mantella);gia
   
    ; target.ClearLookAt()
    ; caster.ClearLookAt()
    
endEvent
