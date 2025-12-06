Scriptname MantellaAction_OffendForgiveFollow extends Quest hidden

Actor Property PlayerRef Auto
MantellaRepository property repository auto
MantellaConstants property mConsts auto
MantellaInterface property EventInterface Auto
Quest Property DGIntimidateQuest Auto
Faction Property MantellaFunctionSourceFaction Auto

event OnInit()
    RegisterForOffendAndForgiveEvents()
EndEvent

event OnPlayerLoadGame()
    RegisterForOffendAndForgiveEvents()
endEvent

Function RegisterForOffendAndForgiveEvents()
    RegisterForModEvent(EventInterface.EVENT_ACTIONS_PREFIX + mConsts.ACTION_NPC_OFFENDED,"OnNpcOffendedActionReceived")
    RegisterForModEvent(EventInterface.EVENT_ACTIONS_PREFIX + mConsts.ACTION_NPC_FORGIVEN,"OnNpcForgivenActionReceived")
    RegisterForModEvent(EventInterface.EVENT_ACTIONS_PREFIX + mConsts.ACTION_NPC_FOLLOW,"OnNpcFollowActionReceived")
    RegisterForModEvent(EventInterface.EVENT_ACTIONS_PREFIX + mConsts.ACTION_NPC_INVENTORY,"OnNpcInventoryActionReceived")
EndFunction

event OnNpcOffendedActionReceived(Form speaker)
    Actor aSpeaker = speaker as Actor
    if (aSpeaker)
        if PlayerRef.isinfaction(repository.giafac_AllowAnger)
            Debug.Notification(aSpeaker.GetDisplayName() + " did not like that.")

            if aSpeaker.GetFactionRank(MantellaFunctionSourceFaction) == 4 ; 4 = Flee faction
                aSpeaker.RemoveFromFaction(MantellaFunctionSourceFaction)
                aSpeaker.EvaluatePackage()
            endIf
            
            ; Add to opposing factions
            aSpeaker.SetFactionRank(repository.MantellaCombatTeamA, 1)
            PlayerRef.SetFactionRank(repository.MantellaCombatTeamB, 1)

            ; Wait for factions to register
            Utility.Wait(0.5)
            aSpeaker.StartCombat(PlayerRef)
            
            ; Remove from factions after combat starts
            Utility.Wait(0.5)
            aSpeaker.RemoveFromFaction(repository.MantellaCombatTeamA)
            PlayerRef.RemoveFromFaction(repository.MantellaCombatTeamB)
        else
            Debug.Notification("Aggro action not enabled in the Mantella MCM.")
        Endif
    endif
endEvent

event OnNpcForgivenActionReceived(Form speaker)
    Actor aSpeaker = speaker as Actor
    if (aSpeaker)
        if PlayerRef.isinfaction(repository.giafac_AllowAnger)
            Debug.Notification(aSpeaker.GetDisplayName() + " forgave you.")
            aSpeaker.StopCombat()

            if aSpeaker.GetFactionRank(MantellaFunctionSourceFaction) == 4 ; 4 = Flee faction
                aSpeaker.RemoveFromFaction(MantellaFunctionSourceFaction)
                aSpeaker.EvaluatePackage()
            endIf

            if DGIntimidateQuest.IsRunning() ; End brawl quest if running
                DGIntimidateQuest.Stop()
            endif
        endif
    endif
endEvent

event OnNpcFollowActionReceived(Form speaker)
    Actor aSpeaker = speaker as Actor
    if (aSpeaker)
        if (aSpeaker.getrelationshiprank(PlayerRef) != "4")
            ;Debug.Notification(actorName + " is willing to follow you.")
            ;target.setrelationshiprank(caster, 4)
            ;target.addtofaction(DunPlayerAllyFactionProperty)
            ;target.addtofaction(PotentialFollowerFactionProperty)
            if PlayerRef.isinfaction(repository.giafac_allowfollower)
                Debug.Notification(aSpeaker.GetDisplayName() + " is following you.");gia
                aSpeaker.SetFactionRank(repository.giafac_following, 1);gia
                repository.gia_FollowerQst.reset();gia
                repository.gia_FollowerQst.stop();gia
                Utility.Wait(0.5);gia
                repository.gia_FollowerQst.start();gia
                aSpeaker.SetActorValue("WaitingForPlayer", 0)
                aSpeaker.EvaluatePackage();gia
            else
                Debug.Notification("Follow action not enabled in the Mantella MCM.")
            endif
        endif
    endif
endEvent

event OnNpcInventoryActionReceived(Form speaker)
    Actor aSpeaker = speaker as Actor
    if (aSpeaker)
        if PlayerRef.isinfaction(repository.fac_AllowInventory)
            aSpeaker.OpenInventory(true)
        else
            Debug.Notification("Inventory action not enabled in the Mantella MCM.")
        endif
    endif
endEvent