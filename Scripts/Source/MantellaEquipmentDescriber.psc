Scriptname MantellaEquipmentDescriber extends Quest hidden

Import SKSE_HTTP

string property Equipment = "mantella_equipment" auto
string property Body = "body" auto
string property Head = "head" auto
string property hands = "hands" auto
string property Feet = "feet" auto
string property Amulet = "amulet" auto
string property RightHand = "righthand" auto
string property LeftHand = "lefthand" auto

int[] _armorSlots
string[] _constants
string[] _spells

event OnInit()
    _armorSlots = new int[5]
    _constants = new string[5]
    _armorSlots[0] = 32
    _constants[0] = Body
    _armorSlots[1] = 31
    _constants[1] = Head
    _armorSlots[2] = 33
    _constants[2] = hands
    _armorSlots[3] = 37
    _constants[3] = Feet
    _armorSlots[4] = 35
    _constants[4] = Amulet
endEvent

int Function AddEquipmentDescription(int handle, Actor actorToDescribeEquipmentOf, bool isPlayer, MantellaRepository repository)
    int equipmentHandle = SKSE_HTTP.createDictionary()
    bool[] trackingOptions
    If (isPlayer)
        trackingOptions = GetPlayerSlotTrackingOptions(repository)
    else
        trackingOptions = GetTargetSlotTrackingOptions(repository)
    EndIf
    int i = 0
    While (i < 5)
        if(trackingOptions[i])
            Armor equippedArmor = actorToDescribeEquipmentOf.GetEquippedArmorInSlot(_armorSlots[i])
            If (equippedArmor)
                SKSE_HTTP.setString(equipmentHandle, _constants[i], equippedArmor.GetName())
            EndIf
        EndIf
        i += 1
    EndWhile
    
    ;Right Hand
    if(trackingOptions[5])
        Weapon equippedWeapon = actorToDescribeEquipmentOf.GetEquippedWeapon(false)
        If (equippedWeapon)
            SKSE_HTTP.setString(equipmentHandle, RightHand, equippedWeapon.GetName())
        EndIf
    EndIf
    ;Offhand
    if(trackingOptions[6])
        Weapon equippedWeapon = actorToDescribeEquipmentOf.GetEquippedWeapon(true)
        If (equippedWeapon)
            SKSE_HTTP.setString(equipmentHandle, LeftHand, equippedWeapon.GetName())
        EndIf
    EndIf

    ; Spells
    if !(isPlayer)
        _spells = GetSpellListFromActor(actorToDescribeEquipmentOf)
        SKSE_HTTP.setStringArray(equipmentHandle, "Spells", _spells)
    endIf
    

    SKSE_HTTP.setNestedDictionary(handle, Equipment, equipmentHandle)
EndFunction


bool[] Function GetPlayerSlotTrackingOptions(MantellaRepository repository)
    bool[] result = new bool[7]
    result[0] = repository.playerEquipmentBody
    result[1] = repository.playerEquipmentHead
    result[2] = repository.playerEquipmentHands
    result[3] = repository.playerEquipmentFeet
    result[4] = repository.playerEquipmentAmulet
    result[5] = repository.playerEquipmentRightHand
    result[6] = repository.playerEquipmentLeftHand
    return result
EndFunction

bool[] Function GetTargetSlotTrackingOptions(MantellaRepository repository)
    bool[] result = new bool[7]
    result[0] = repository.targetEquipmentBody
    result[1] = repository.targetEquipmentHead
    result[2] = repository.targetEquipmentHands
    result[3] = repository.targetEquipmentFeet
    result[4] = repository.targetEquipmentAmulet
    result[5] = repository.targetEquipmentRightHand
    result[6] = repository.targetEquipmentLeftHand
    return result
EndFunction


string[] Function GetSpellListFromActor(actor currentActor)
    int i = 0
    int spellIndex = 0
    int actorSpellCount = currentActor.GetSpellCount()
    string[] spellNames = new string[5] ; Limit to first 5 spells

    ; First, get spells from Actor reference
    while (i < actorSpellCount) && (spellIndex < 5)
        string spellName = currentActor.GetNthSpell(i).getName()
        if spellName != "MantellaIsTalkingSpell"
            spellNames[spellIndex] = spellName
            spellIndex += 1
        endIf
        i += 1
    endwhile

    ; If we haven't reached 5 spells yet, check ActorBase spells
    if spellIndex < 5
        ActorBase currentActorBase = currentActor.GetActorBase()
        int actorBaseSpellCount = currentActorBase.GetSpellCount()
        int j = 0
        
        while (j < actorBaseSpellCount) && (spellIndex < 5)
            string spellName = currentActorBase.GetNthSpell(j).getName()
            if spellName != "MantellaIsTalkingSpell"
                spellNames[spellIndex] = spellName
                spellIndex += 1
            endIf
            j += 1
        endwhile
    endIf

    return spellNames
Endfunction