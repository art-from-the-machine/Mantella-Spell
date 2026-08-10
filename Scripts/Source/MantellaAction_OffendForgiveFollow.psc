Scriptname MantellaAction_OffendForgiveFollow extends Quest hidden

Actor Property PlayerRef Auto
MantellaRepository property repository auto
MantellaConstants property mConsts auto
MantellaInterface property EventInterface Auto
Quest Property DGIntimidateQuest Auto
Faction Property MantellaFunctionSourceFaction Auto
MantellaConversation Property conversation Auto

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
    endif
endEvent

event OnNpcForgivenActionReceived(Form speaker)
    Actor aSpeaker = speaker as Actor
    if (aSpeaker)
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
endEvent

event OnNpcFollowActionReceived(Form speaker)
    int actorCount = 0
    if (conversation)
        actorCount = conversation.CountActorsInConversation()
    endif

    if (actorCount == 0)
        ; Conversation unavailable: fall back to the speaker only
        NpcFollow(speaker as Actor)
        return
    endif

    ; Apply the follow action to every NPC in the conversation
    bool anyNewFollowers = false
    int i = 0
    While i < actorCount
        Actor participant = conversation.GetActorInConversationByIndex(i)
        if (participant && participant != PlayerRef && participant.getrelationshiprank(PlayerRef) != 4)
            Debug.Notification(participant.GetDisplayName() + " is following you.")
            participant.SetFactionRank(repository.giafac_following, 1)
            participant.SetActorValue("WaitingForPlayer", 0)
            anyNewFollowers = true
        endif
        i += 1
    EndWhile

    ; Restart the follower quest once after all faction ranks are set so its
    ; aliases pick up every new follower in a single fill
    if (anyNewFollowers)
        repository.gia_FollowerQst.reset()
        repository.gia_FollowerQst.stop()
        Utility.Wait(0.5)
        repository.gia_FollowerQst.start()
        i = 0
        While i < actorCount
            Actor participant = conversation.GetActorInConversationByIndex(i)
            if (participant && participant != PlayerRef)
                participant.EvaluatePackage()
            endif
            i += 1
        EndWhile
    endif
endEvent

Function NpcFollow(Actor aSpeaker)
    if (aSpeaker)
        if (aSpeaker.getrelationshiprank(PlayerRef) != 4)
            Debug.Notification(aSpeaker.GetDisplayName() + " is following you.");gia
            aSpeaker.SetFactionRank(repository.giafac_following, 1);gia
            repository.gia_FollowerQst.reset();gia
            repository.gia_FollowerQst.stop();gia
            Utility.Wait(0.5);gia
            repository.gia_FollowerQst.start();gia
            aSpeaker.SetActorValue("WaitingForPlayer", 0)
            aSpeaker.EvaluatePackage();gia
        endif
    endif
EndFunction

event OnNpcInventoryActionReceived(Form speaker)
    Actor aSpeaker = speaker as Actor
    MantellaAdvancedAction_Inventory inventoryHandler = Quest.GetQuest("MantellaAdvancedAction_Inventory") as MantellaAdvancedAction_Inventory
    if inventoryHandler
        inventoryHandler.NpcInventory(aSpeaker)
    elseIf aSpeaker
        ; Compatibility fallback for saves where the advanced Inventory quest is
        ; unavailable. The UI remains authoritative even without the snapshot.
        aSpeaker.OpenInventory(true)
    endif
endEvent
