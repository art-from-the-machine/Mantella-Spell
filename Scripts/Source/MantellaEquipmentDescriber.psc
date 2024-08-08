Scriptname MantellaEquipmentDescriber extends Quest hidden

Import SKSE_HTTP

string property EQUIPMENT = "mantella_equipment" auto
string property BODY = "body" auto
string property HEAD = "head" auto
string property HANDS = "hands" auto
string property FEET = "feet" auto
string property AMULET = "amulet" auto
string property RIGHTHAND = "righthand" auto
string property LEFTHAND = "lefthand" auto

int[] _armorSlots
string[] _constants

event OnInit()
    _armorSlots = new int[5]
    _constants = new string[5]
    _armorSlots[0] = 32
    _constants[0] = BODY
    _armorSlots[1] = 31
    _constants[1] = HEAD
    _armorSlots[2] = 33
    _constants[2] = HANDS
    _armorSlots[3] = 37
    _constants[3] = FEET
    _armorSlots[4] = 35
    _constants[4] = AMULET
endEvent

int Function AddEquipmentDescription(int handle, Actor actorToDescribeEquipmentOf)
    int equipmentHandle = SKSE_HTTP.createDictionary()
    int i = 0
    While (i < 5)
        Armor equippedArmor = actorToDescribeEquipmentOf.GetEquippedArmorInSlot(_armorSlots[i])
        If (equippedArmor)
            SKSE_HTTP.setString(equipmentHandle, _constants[i], equippedArmor.GetName())
        EndIf
        i += 1
    EndWhile
    
    ;Right Hand
    Weapon equippedWeapon = actorToDescribeEquipmentOf.GetEquippedWeapon(false)
    If (equippedWeapon)
        SKSE_HTTP.setString(equipmentHandle, RIGHTHAND, equippedWeapon.GetName())
    EndIf
    ;Offhand
    equippedWeapon = actorToDescribeEquipmentOf.GetEquippedWeapon(true)
    If (equippedWeapon)
        SKSE_HTTP.setString(equipmentHandle, LEFTHAND, equippedWeapon.GetName())
    EndIf
    SKSE_HTTP.setNestedDictionary(handle, EQUIPMENT, equipmentHandle)
EndFunction

