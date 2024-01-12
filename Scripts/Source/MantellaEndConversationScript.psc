Scriptname MantellaEndConversationScript extends activemagiceffect  

event OnEffectStart(Actor target, Actor caster)
    MiscUtil.WriteToFile("_mantella_end_conversation.txt", "True",  append=false)
endEvent