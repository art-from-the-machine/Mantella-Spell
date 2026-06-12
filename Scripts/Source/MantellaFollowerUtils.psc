Scriptname MantellaFollowerUtils Hidden

; Dismiss a single follower by clearing only their alias on the follower quest.
; Restarting the quest would empty every alias and stop all other followers.
Function DismissFollower(Actor speaker, Quest followerQuest, Faction followingFaction) Global
    speaker.RemoveFromFaction(followingFaction)
    int i = followerQuest.GetNumAliases()
    While i > 0
        i -= 1
        ReferenceAlias followerAlias = followerQuest.GetNthAlias(i) as ReferenceAlias
        if followerAlias && followerAlias.GetActorReference() == speaker
            followerAlias.Clear()
        endif
    EndWhile
    speaker.EvaluatePackage()
EndFunction
