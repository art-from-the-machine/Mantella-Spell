Scriptname MantellaAdvancedAction_CastSpell extends Quest Hidden

MantellaInterface Property EventInterface Auto
Faction Property MantellaFunctionSourceFaction Auto
SPELL Property MantellaDummySpell Auto
mantellaconstants Property mConsts Auto
ReferenceAlias Property CastSpellSourceAlias Auto
ReferenceAlias Property CastSpellTargetAlias Auto

Spell spellToUse = none
Spell Function GetSpellToUse()
    return spellToUse
EndFunction


event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_CASTSPELL, "OnNpcCastSpellAdvancedActionReceived")
EndEvent


event OnNpcCastSpellAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)
    spellToUse = none ; Reset spellToUse
    MantellaConversation conversation = conversationQuest as MantellaConversation
    
    ; Extract NPC names from parameters
    string sourceName = SKSE_HTTP.getString(argumentsHandle, mConsts.ACTION_ARG_SOURCE)
    string targetName = SKSE_HTTP.getString(argumentsHandle, mConsts.ACTION_ARG_TARGET)
    string spellName = SKSE_HTTP.getString(argumentsHandle, "spellName")

    Actor sourceActor = conversation.GetActorByName(sourceName)
    Actor targetActor = conversation.GetActorByName(targetName)
    spellToUse = GetSpellFromActor(spellName, sourceActor)

    if sourceActor && targetActor && spellToUse
        if sourceActor.IsPlayerTeammate()
            if (sourceActor.GetActorValue("WaitingForPlayer") == 1)
                ; Clear wait so the NPC can cast spell
                sourceActor.SetActorValue("WaitingForPlayer", 0)
            endif
        endif

        if sourceActor == targetActor
            Debug.Notification(sourceName + " casts / uses " + spellName + " on themselves")
            spellToUse.Cast(sourceActor, targetActor)
        else    
            Debug.Notification(sourceName + " casts / uses " + spellName + " on " + targetName)

            CastSpellTargetAlias.ForceRefTo(targetActor)

            sourceActor.AddSpell(MantellaDummySpell)
            sourceActor.SetFactionRank(MantellaFunctionSourceFaction, 6)
            CastSpellSourceAlias.ForceRefTo(sourceActor)

            sourceActor.EvaluatePackage()
        endIf
    elseIf !(targetActor)
        Debug.Notification("Target actor " + targetName + " not found.")
    endIf
endEvent


Spell Function GetSpellFromActor(string SpellNameToFind, actor currentActor)
    string availableSpells = ""

    ; First check Actor reference spells
    int i = 0
    while i < currentActor.GetSpellCount() 
        Spell currentSpell = currentActor.GetNthSpell(i)
        string spellName = currentSpell.getName()
        availableSpells += spellName + ", "
        if spellName == SpellNameToFind
            return currentSpell
        endif
        i += 1
    endwhile
    
    ; If not found on Actor reference, check ActorBase spells
    ActorBase currentActorBase = currentActor.GetActorBase()
    int j = 0
    while j < currentActorBase.GetSpellCount()
        Spell currentSpell = currentActorBase.GetNthSpell(j)
        string spellName = currentSpell.getName()
        availableSpells += spellName + ", "
        if spellName == SpellNameToFind
            return currentSpell
        endif
        j += 1
    endwhile
    
    ; Give immediate player feedback if spell not found
    Debug.Notification(currentActor.GetDisplayName() + " does not know the spell " + SpellNameToFind)
    ; Give full details to LLM
    EventInterface.AddMantellaEvent(currentActor.GetDisplayName() + " does not know the spell " + SpellNameToFind + ". Available spells: " + availableSpells)
    return none
Endfunction