Scriptname MantellaEndConversationScript extends activemagiceffect  

; event OnEffectStart(Actor target, Actor caster)
;     MiscUtil.WriteToFile("_mantella_end_conversation.txt", "True",  append=false)
; endEvent

event OnEffectStart(Actor target, Actor caster)
    MantellaConversation conversation = Quest.GetQuest("MantellaConversation") as MantellaConversation
    if(conversation.IsRunning())
        conversation.EndConversation()
    endIf
endEvent