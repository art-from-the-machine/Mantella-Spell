;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname gia_castMantellaSpell Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
gia_Mantellaspell.cast(game.getplayer(),akspeaker)
game.getplayer().AddToFaction(giafac_mantella)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Spell property gia_MantellaSpell Auto
Faction property giafac_Mantella Auto
