Scriptname MantellaManagedEquipmentAlias extends ReferenceAlias Hidden

; OnCellAttach is delivered by Skyrim only for the actor held by this alias.
; The Equip quest batches attached actors into one delayed update so default
; outfit evaluation finishes before managed slots are checked. This is
; event-driven, not a polling loop.
Event OnCellAttach()
    MantellaAdvancedAction_Equip equipManager = GetOwningQuest() as MantellaAdvancedAction_Equip
    if equipManager
        Actor sourceActor = GetActorReference()
        equipManager.TryManagedEquipmentRestoreImmediately(sourceActor, "managed alias OnCellAttach")
        equipManager.QueueManagedEquipmentRestore(sourceActor)
    endIf
EndEvent

; Skyrim sends this after every object in the parent cell is loaded. It is the
; latest no-delay lifecycle point before the queued fallback and often occurs
; after outfit evaluation has selected the default apparel.
Event OnCellLoad()
    MantellaAdvancedAction_Equip equipManager = GetOwningQuest() as MantellaAdvancedAction_Equip
    if equipManager
        Actor sourceActor = GetActorReference()
        equipManager.TryManagedEquipmentRestoreImmediately(sourceActor, "managed alias OnCellLoad")
        equipManager.QueueManagedEquipmentRestore(sourceActor)
    endIf
EndEvent

; Some follower/location transitions restore outfits without delivering a
; second OnCellAttach to a dynamically filled alias.  OnLoad is the companion
; lifecycle signal; the quest still deduplicates and delays the actual check.
Event OnLoad()
    MantellaAdvancedAction_Equip equipManager = GetOwningQuest() as MantellaAdvancedAction_Equip
    if equipManager
        Actor sourceActor = GetActorReference()
        equipManager.TryManagedEquipmentRestoreImmediately(sourceActor, "managed alias OnLoad")
        equipManager.QueueManagedEquipmentRestore(sourceActor)
    endIf
EndEvent

Event OnDeath(Actor akKiller)
    MantellaAdvancedAction_Equip equipManager = GetOwningQuest() as MantellaAdvancedAction_Equip
    if equipManager
        equipManager.ForgetManagedEquipment(GetActorReference())
    endIf
EndEvent
