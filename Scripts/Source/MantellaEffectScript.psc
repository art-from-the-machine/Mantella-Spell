Scriptname MantellaEffectScript extends activemagiceffect

MantellaConversation property conversation auto

event OnEffectStart(Actor target, Actor caster)
    Utility.Wait(0.5)
    Actor[] actors = new Actor[2]
    actors[0] = caster
    actors[1] = target
    if(!conversation.IsRunning())
        conversation.Start()
        conversation.StartConversation(actors)
    Else
        conversation.AddActorsToConversation(actors)
    endIf
endEvent
