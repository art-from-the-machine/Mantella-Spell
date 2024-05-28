Scriptname MantellaAction_OffendForgiveFollow extends Quest hidden

MantellaRepository property repository auto
MantellaConstants property mConsts auto

event OnInit()
    RegisterForOffendAndForgiveEvents()
EndEvent

event OnPlayerLoadGame()
    RegisterForOffendAndForgiveEvents()
endEvent

Function RegisterForOffendAndForgiveEvents()
    RegisterForModEvent(mConsts.EVENT_ACTIONS + mConsts.ACTION_NPC_OFFENDED,"OnNpcOffendedActionReceived")
    RegisterForModEvent(mConsts.EVENT_ACTIONS + mConsts.ACTION_NPC_FORGIVEN,"OnNpcForgivenActionReceived")
    RegisterForModEvent(mConsts.EVENT_ACTIONS + mConsts.ACTION_NPC_FOLLOW,"OnNpcFollowActionReceived")
EndFunction

event OnNpcOffendedActionReceived(Form speaker, string sentence)
    Actor aSpeaker = speaker as Actor
    if (aSpeaker)
        if game.getplayer().isinfaction(repository.giafac_AllowAnger)
            Debug.Notification(aSpeaker.GetDisplayName() + " did not like that.")
            ;target.UnsheatheWeapon()
            ;target.SendTrespassAlarm(caster)
            aSpeaker.StartCombat(game.getplayer())
        else
            Debug.Notification("Aggro action not enabled in the Mantella MCM.")
        Endif
    endif
endEvent

event OnNpcForgivenActionReceived(Form speaker, string sentence)
    Actor aSpeaker = speaker as Actor
    if (aSpeaker)
        if game.getplayer().isinfaction(repository.giafac_AllowAnger)
            Debug.Notification(aSpeaker.GetDisplayName() + " forgave you.")
            aSpeaker.StopCombat()
        endif
    endif
endEvent

event OnNpcFollowActionReceived(Form speaker, string sentence)
    Actor aSpeaker = speaker as Actor
    if (aSpeaker)
        if (aSpeaker.getrelationshiprank(game.getplayer()) != "4")
            ;Debug.Notification(actorName + " is willing to follow you.")
            ;target.setrelationshiprank(caster, 4)
            ;target.addtofaction(DunPlayerAllyFactionProperty)
            ;target.addtofaction(PotentialFollowerFactionProperty)
            if game.getplayer().isinfaction(repository.giafac_allowfollower)
                Debug.Notification(aSpeaker.GetDisplayName() + " is following you.");gia
                aSpeaker.SetFactionRank(repository.giafac_following, 1);gia
                repository.gia_FollowerQst.reset();gia
                repository.gia_FollowerQst.stop();gia
                Utility.Wait(0.5);gia
                repository.gia_FollowerQst.start();gia
                aSpeaker.EvaluatePackage();gia
            else
                Debug.Notification("Follow action not enabled in the Mantella MCM.")
            endif
        endif
    endif
endEvent

; Check aggro status after every line spoken
;         String aggro = MiscUtil.ReadFromFile("_mantella_aggro.txt") as String
;         if aggro == "0"
;             if game.getplayer().isinfaction(Repository.giafac_AllowAnger)
;                 Debug.Notification(actorName + " forgave you.")
;                 target.StopCombat()
; 			endif
;             MiscUtil.WriteToFile("_mantella_aggro.txt", "",  append=false)
;         elseIf aggro == "1"
;             if game.getplayer().isinfaction(Repository.giafac_AllowAnger)
;                 Debug.Notification(actorName + " did not like that.")
;                 ;target.UnsheatheWeapon()
;                 ;target.SendTrespassAlarm(caster)
;                 target.StartCombat(caster)
;             else
;                 Debug.Notification("Aggro action not enabled in the Mantella MCM.")
; 			Endif
;             MiscUtil.WriteToFile("_mantella_aggro.txt", "",  append=false)
;         elseif aggro == "2"
;             if actorRelationship != "4"
;                 ;Debug.Notification(actorName + " is willing to follow you.")
;                 ;target.setrelationshiprank(caster, 4)
;                 ;target.addtofaction(DunPlayerAllyFactionProperty)
;                 ;target.addtofaction(PotentialFollowerFactionProperty)
;                 if game.getplayer().isinfaction(repository.giafac_allowfollower)
; 					Debug.Notification(actorName + " is following you.");gia
; 					target.SetFactionRank(repository.giafac_following, 1);gia
; 					repository.gia_FollowerQst.reset();gia
; 					repository.gia_FollowerQst.stop();gia
; 					Utility.Wait(0.5);gia
; 					repository.gia_FollowerQst.start();gia
; 					target.EvaluatePackage();gia
;                 else
;                     Debug.Notification("Follow action not enabled in the Mantella MCM.")
; 				endif

;                 MiscUtil.WriteToFile("_mantella_aggro.txt", "",  append=false)
;             endIf
;         endIf