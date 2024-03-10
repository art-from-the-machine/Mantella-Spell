Scriptname MantellaRadiantDialogue extends Quest hidden

; MantellaRepository property repository auto
; ; ReferenceAlias Property PotentialActor1  auto  
; ; ReferenceAlias Property PotentialActor2  auto
; Spell property MantellaSpell auto
; MantellaConversation property conversation auto
; Quest property picker auto

; event OnInit()
;     RegisterForSingleUpdate(repository.radiantFrequency)
; EndEvent

; event OnPlayerLoadGame()
;     RegisterForSingleUpdate(repository.radiantFrequency)
; endEvent

; event OnUpdate()
;     if repository.radiantEnabled
;         TryStartRadiantDialogue()        
;     endIf
;     RegisterForSingleUpdate(repository.radiantFrequency)
; endEvent

; Function TryStartRadiantDialogue()
;     if(conversation.IsRunning())
;         return
;     endIf
   
;     ;MantellaActorList taken from this tutorial:
;     ;http://skyrimmw.weebly.com/skyrim-modding/detecting-nearby-actors-skyrim-modding-tutorial
;     ; if both actors found

;     picker.Start()

;     Actor PotentialActor1 = (picker.GetAliasByName("PotentialActor1") as ReferenceAlias).GetReference() as Actor
;     Actor PotentialActor2 = (picker.GetAliasByName("PotentialActor2") as ReferenceAlias).GetReference() as Actor

;     if (PotentialActor1 && PotentialActor2)
;         float distanceToClosestActor = game.getplayer().GetDistance(PotentialActor1)
;         float maxDistance = ConvertMeterToGameUnits(repository.radiantDistance)
;         if distanceToClosestActor <= maxDistance
;             String Actor1Name = PotentialActor1.getdisplayname()
;             String Actor2Name = PotentialActor2.getdisplayname()
;             float distanceBetweenActors = PotentialActor1.GetDistance(PotentialActor2)

;             ;TODO: make distanceBetweenActors customisable
;             if (distanceBetweenActors <= 1000)
;                 ;have spell casted on Actor 1 by Actor 2
;                 MantellaSpell.Cast(PotentialActor2 as ObjectReference, PotentialActor1 as ObjectReference)
;             else
;                 ;TODO: make this notification optional
;                 Debug.Notification("Radiant dialogue attempted. No NPCs close enough to each other")
;             endIf
;         else
;             ;TODO: make this notification optional
;             Debug.Notification("Radiant dialogue attempted. NPCs too far away at " + ConvertGameUnitsToMeter(distanceToClosestActor) + " meters")
;             Debug.Notification("Max distance set to " + repository.radiantDistance + "m in Mantella MCM")
;         endIf
;     else
;         Debug.Notification("Radiant dialogue attempted. No NPCs available")
;     endIf

;     picker.Stop()

; EndFunction

; Float meterUnits = 71.0210
; Float Function ConvertMeterToGameUnits(Float meter)
;     Return Meter * meterUnits
; EndFunction

; Float Function ConvertGameUnitsToMeter(Float gameUnits)
;     Return gameUnits / meterUnits
; EndFunction