Scriptname MantellaDummyEffectScript extends ActiveMagicEffect

SPELL Property MantellaDummySpell Auto
Faction Property MantellaFunctionSourceFaction Auto
MantellaAdvancedAction_CastSpell Property CastSpellScript Auto

event OnEffectStart(Actor target, Actor caster)
    Spell spellToUse = CastSpellScript.GetSpellToUse()
    float magickaCost = spellToUse.GetEffectiveMagickaCost(caster)

    If caster.GetAV("Magicka") >= magickaCost
        Debug.Notification(caster.GetDisplayName() + " is casting " + spellToUse.GetName())
        spellToUse.Cast(caster, target)
        Utility.Wait(1.0)
        caster.DamageAV("Magicka", caster.GetAV("Magicka")) ; Drain all magicka to prevent continuous casting
    Else
        Debug.Notification(caster.GetDisplayName() + " does not have enough magicka to cast " + spellToUse.GetName())
    endif
    caster.RemoveSpell(MantellaDummySpell)
    caster.RemoveFromFaction(MantellaFunctionSourceFaction)
    caster.EvaluatePackage()
EndEvent