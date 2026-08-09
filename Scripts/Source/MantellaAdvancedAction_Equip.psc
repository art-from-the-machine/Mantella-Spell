Scriptname MantellaAdvancedAction_Equip extends Quest Hidden

MantellaInterface Property EventInterface Auto
MantellaConstants Property mConsts Auto
MantellaConversation Property Conversation Auto

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ACTIONS_PREFIX + mConsts.ACTION_NPC_EQUIP, "OnNpcEquipActionReceived")
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_EQUIP, "OnNpcEquipAdvancedActionReceived")
EndEvent

event OnNpcEquipActionReceived(Form speaker)
    HandleEquipAction(speaker, None, 0)
endEvent

event OnNpcEquipAdvancedActionReceived(Form speaker, Form conversationQuest, int argumentsHandle)
    HandleEquipAction(speaker, conversationQuest, argumentsHandle)
endEvent

Function HandleEquipAction(Form speaker, Form conversationQuest, int argumentsHandle)
    MantellaConversation activeConversation = conversationQuest as MantellaConversation
    if !activeConversation
        activeConversation = Conversation
    endIf
    Actor sourceActor = speaker as Actor
    string requestedItemName = "best armor"

    if argumentsHandle != 0
        string sourceName = SKSE_HTTP.getString(argumentsHandle, mConsts.ACTION_ARG_SOURCE, "")
        if activeConversation && sourceName != ""
            Actor resolvedActor = activeConversation.GetActorByName(sourceName)
            if resolvedActor
                sourceActor = resolvedActor
            endIf
        endIf
        requestedItemName = SKSE_HTTP.getString(argumentsHandle, "item_name", "best armor")
    endIf

    if !sourceActor
        EventInterface.AddMantellaEvent("Equip failed: the requested NPC could not be found.")
        EventInterface.MarkActionResponseCompleted(mConsts.ACTION_NPC_EQUIP)
        return
    endIf

    bool success = EquipRequestedItem(sourceActor, requestedItemName)
    if success
        sourceActor.QueueNiNodeUpdate()
        Utility.Wait(0.10)
        if activeConversation
            activeConversation.RefreshActorEquipmentState()
        endIf
        EventInterface.AddMantellaEvent(sourceActor.GetDisplayName() + "'s current equipment has been refreshed after the verified equip.")
    endIf

    EventInterface.MarkActionResponseCompleted(mConsts.ACTION_NPC_EQUIP)
EndFunction

bool Function EquipRequestedItem(Actor sourceActor, string requestedItemName)
    string normalizedRequest = ToLowerAscii(requestedItemName)

    if IsGenericArmorRequest(normalizedRequest)
        int equippedCount = EquipBestArmorSet(sourceActor)
        if equippedCount > 0
            EventInterface.AddMantellaEvent(sourceActor.GetDisplayName() + " equipped the best available armor from their inventory.")
            return true
        endIf
        EventInterface.AddMantellaEvent(sourceActor.GetDisplayName() + " has no armor in their inventory that Skyrim could equip.")
        return false
    elseIf IsGenericWeaponRequest(normalizedRequest)
        Weapon bestWeapon = FindBestWeapon(sourceActor)
        if !bestWeapon
            EventInterface.AddMantellaEvent(sourceActor.GetDisplayName() + " has no weapon in their inventory to equip.")
            return false
        endIf
        if EquipAndVerify(sourceActor, bestWeapon)
            EventInterface.AddMantellaEvent(sourceActor.GetDisplayName() + " equipped " + bestWeapon.GetName() + ".")
            return true
        endIf
        EventInterface.AddMantellaEvent(sourceActor.GetDisplayName() + " owns " + bestWeapon.GetName() + ", but Skyrim did not equip it.")
        return false
    endIf

    Form requestedItem = FindEquipableItemByName(sourceActor, normalizedRequest)
    if !requestedItem
        EventInterface.AddMantellaEvent(sourceActor.GetDisplayName() + " has no equippable inventory item matching '" + requestedItemName + "'.")
        return false
    endIf
    if EquipAndVerify(sourceActor, requestedItem)
        EventInterface.AddMantellaEvent(sourceActor.GetDisplayName() + " equipped " + requestedItem.GetName() + ".")
        return true
    endIf

    EventInterface.AddMantellaEvent(sourceActor.GetDisplayName() + " owns " + requestedItem.GetName() + ", but Skyrim did not equip it.")
    return false
EndFunction

bool Function EquipAndVerify(Actor sourceActor, Form itemForm)
    if !sourceActor || !itemForm || sourceActor.GetItemCount(itemForm) <= 0
        return false
    endIf

    sourceActor.EquipItem(itemForm, false, true)
    Utility.Wait(0.05)
    if !sourceActor.IsEquipped(itemForm)
        sourceActor.EquipItemEx(itemForm, 0, false, false)
        Utility.Wait(0.05)
    endIf

    return sourceActor.IsEquipped(itemForm)
EndFunction

Form Function FindEquipableItemByName(Actor sourceActor, string normalizedRequest)
    if !sourceActor || normalizedRequest == ""
        return None
    endIf

    int itemCount = sourceActor.GetNumItems()
    int i = 0
    Form itemForm = None
    string normalizedInventoryName = ""

    While i < itemCount
        itemForm = sourceActor.GetNthForm(i)
        if IsEquipableForm(itemForm) && sourceActor.GetItemCount(itemForm) > 0
            normalizedInventoryName = ToLowerAscii(itemForm.GetName())
            if normalizedInventoryName == normalizedRequest
                return itemForm
            endIf
        endIf
        i += 1
    EndWhile

    i = 0
    While i < itemCount
        itemForm = sourceActor.GetNthForm(i)
        if IsEquipableForm(itemForm) && sourceActor.GetItemCount(itemForm) > 0
            normalizedInventoryName = ToLowerAscii(itemForm.GetName())
            if normalizedInventoryName != ""
                if StringUtil.Find(normalizedInventoryName, normalizedRequest) >= 0 || StringUtil.Find(normalizedRequest, normalizedInventoryName) >= 0
                    return itemForm
                endIf
            endIf
        endIf
        i += 1
    EndWhile

    return None
EndFunction

string Function ToLowerAscii(string value)
    string result = ""
    int valueLength = StringUtil.GetLength(value)
    int i = 0

    While i < valueLength
        string character = StringUtil.GetNthChar(value, i)
        int characterCode = StringUtil.AsOrd(character)
        if characterCode >= 65 && characterCode <= 90
            character = StringUtil.AsChar(characterCode + 32)
        endIf
        result += character
        i += 1
    EndWhile

    return result
EndFunction

bool Function IsEquipableForm(Form itemForm)
    if itemForm as Armor
        return true
    elseIf itemForm as Weapon
        return true
    elseIf itemForm as Ammo
        return true
    endIf
    return false
EndFunction

bool Function IsGenericArmorRequest(string normalizedRequest)
    return normalizedRequest == "" || normalizedRequest == "armor" || normalizedRequest == "armour" || normalizedRequest == "best armor" || normalizedRequest == "best armour" || normalizedRequest == "your armor" || normalizedRequest == "your armour" || normalizedRequest == "gear" || normalizedRequest == "your gear" || normalizedRequest == "clothes" || normalizedRequest == "clothing" || normalizedRequest == "best clothing"
EndFunction

bool Function IsGenericWeaponRequest(string normalizedRequest)
    return normalizedRequest == "weapon" || normalizedRequest == "best weapon" || normalizedRequest == "your weapon"
EndFunction

int Function EquipBestArmorSet(Actor sourceActor)
    int equippedCount = 0
    int selectedMask = 0
    int desiredMask = Armor.GetMaskForSlot(30) + Armor.GetMaskForSlot(31) + Armor.GetMaskForSlot(32) + Armor.GetMaskForSlot(33) + Armor.GetMaskForSlot(37)
    bool searchForNextPiece = true

    While searchForNextPiece
        Armor bestArmor = None
        int bestRating = -1
        int itemCount = sourceActor.GetNumItems()
        int i = 0

        While i < itemCount
            Armor armorItem = sourceActor.GetNthForm(i) as Armor
            if armorItem && sourceActor.GetItemCount(armorItem) > 0
                int armorMask = armorItem.GetSlotMask()
                if Math.LogicalAnd(armorMask, desiredMask) != 0 && Math.LogicalAnd(armorMask, selectedMask) == 0
                    int armorRating = armorItem.GetArmorRating()
                    if armorRating > bestRating
                        bestRating = armorRating
                        bestArmor = armorItem
                    endIf
                endIf
            endIf
            i += 1
        EndWhile

        if bestArmor
            selectedMask += bestArmor.GetSlotMask()
            if EquipAndVerify(sourceActor, bestArmor)
                equippedCount += 1
            endIf
        else
            searchForNextPiece = false
        endIf
    EndWhile

    return equippedCount
EndFunction

Weapon Function FindBestWeapon(Actor sourceActor)
    Weapon bestWeapon = None
    int bestDamage = -1
    int itemCount = sourceActor.GetNumItems()
    int i = 0

    While i < itemCount
        Weapon weaponItem = sourceActor.GetNthForm(i) as Weapon
        if weaponItem && sourceActor.GetItemCount(weaponItem) > 0
            int weaponDamage = weaponItem.GetBaseDamage()
            if weaponDamage > bestDamage
                bestDamage = weaponDamage
                bestWeapon = weaponItem
            endIf
        endIf
        i += 1
    EndWhile

    return bestWeapon
EndFunction
