Scriptname MantellaAdvancedAction_Equip extends Quest Hidden

MantellaInterface Property EventInterface Auto
MantellaConstants Property mConsts Auto
MantellaConversation Property Conversation Auto

; Save-persistent, Form-based desired equipment. The quest owns one alias per
; managed actor so Skyrim can forward OnCellAttach without global polling.
Form[] managedActors
Form[] managedItems
int[] managedSlotMasks
int[] managedCategories
Form[] pendingRestoreActors
int[] pendingRestoreAttempts
bool isRestoringManagedEquipment = false
Actor restoringActor = None

int PROPERTY MANAGED_ARMOR = 1 AutoReadOnly
int PROPERTY MANAGED_WEAPON = 2 AutoReadOnly
int PROPERTY MANAGED_AMMO = 3 AutoReadOnly

event OnInit()
    RegisterForModEvent(EventInterface.EVENT_ACTIONS_PREFIX + mConsts.ACTION_NPC_EQUIP, "OnNpcEquipActionReceived")
    RegisterForModEvent(EventInterface.EVENT_ADVANCED_ACTIONS_PREFIX + mConsts.ACTION_NPC_EQUIP, "OnNpcEquipAdvancedActionReceived")
EndEvent

Event OnPlayerLoadGame()
    ; Quest arrays are save-persistent, but dynamically filled aliases may not
    ; receive a lifecycle callback on every load. Reattach through the same
    ; bounded, delayed restore path without touching unmanaged actors.
    EnsureManagedState()
    int i = 0
    While i < managedActors.Length
        Actor sourceActor = managedActors[i] as Actor
        if sourceActor
            QueueManagedEquipmentRestoreForActor(sourceActor)
        endIf
        i += 1
    EndWhile
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
    elseIf IsGenericShieldRequest(normalizedRequest)
        Armor bestShield = FindBestShield(sourceActor)
        if !bestShield
            EventInterface.AddMantellaEvent(sourceActor.GetDisplayName() + " has no shield in their inventory to equip.")
            return false
        endIf
        if EquipAndVerify(sourceActor, bestShield)
            EventInterface.AddMantellaEvent(sourceActor.GetDisplayName() + " equipped " + bestShield.GetName() + ".")
            return true
        endIf
        EventInterface.AddMantellaEvent(sourceActor.GetDisplayName() + " owns " + bestShield.GetName() + ", but Skyrim did not equip it.")
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

    ; Release a conflicting item first so a later explicit Mantella request can
    ; replace equipment that an earlier request protected from outfit resets.
    isRestoringManagedEquipment = true
    restoringActor = sourceActor
    ReleaseConflictingEquipment(sourceActor, itemForm)

    sourceActor.EquipItem(itemForm, true, true)
    Utility.Wait(0.05)
    if !sourceActor.IsEquipped(itemForm)
        sourceActor.EquipItemEx(itemForm, 0, true, false)
        Utility.Wait(0.05)
    endIf

    bool verified = sourceActor.IsEquipped(itemForm)
    restoringActor = None
    isRestoringManagedEquipment = false
    if verified
        RecordManagedEquipment(sourceActor, itemForm)
    endIf
    return verified
EndFunction

; Called by the actor listener when Skyrim's outfit/equipment evaluation changes
; an item on an actor with Mantella-managed slots.  It is deliberately a no-op
; for unrelated actors and does not emit a game event or start an LLM turn.
Function QueueManagedEquipmentRestoreIfNeeded(Actor sourceActor, Form changedItem)
    QueueManagedEquipmentRestoreForActor(sourceActor)
EndFunction

; Outfit evaluation may report only the replacement item (for example Belted
; Tunic) and not the managed item that was removed.  Queue a single delayed
; check for any actor with managed state so either event shape is handled.
Function QueueManagedEquipmentRestoreForActor(Actor sourceActor)
    EnsureManagedState()
    if !sourceActor || IsRestoringEquipmentFor(sourceActor) || !HasManagedEquipment(sourceActor)
        return
    endIf
    QueueManagedEquipmentRestore(sourceActor)
EndFunction

Function EnsureManagedState()
    if managedActors == None
        managedActors = Utility.CreateFormArray(0)
    endIf
    if managedItems == None
        managedItems = Utility.CreateFormArray(0)
    endIf
    if managedSlotMasks == None
        managedSlotMasks = Utility.CreateIntArray(0)
    endIf
    if managedCategories == None
        managedCategories = Utility.CreateIntArray(0)
    endIf
    if pendingRestoreActors == None
        pendingRestoreActors = Utility.CreateFormArray(0)
    endIf
    if pendingRestoreAttempts == None
        pendingRestoreAttempts = Utility.CreateIntArray(0)
    endIf
EndFunction

Function RecordManagedEquipment(Actor sourceActor, Form itemForm)
    EnsureManagedState()
    int category = GetManagedCategory(itemForm)
    if category == 0 || !EnsureManagedActorAlias(sourceActor)
        return
    endIf

    int slotMask = GetManagedSlotMask(itemForm)
    int i = managedItems.Length - 1
    While i >= 0
        if managedActors[i] == sourceActor && ManagedEntriesConflict(category, slotMask, managedCategories[i], managedSlotMasks[i])
            RemoveManagedEntry(i)
        endIf
        i -= 1
    EndWhile

    managedActors = Utility.ResizeFormArray(managedActors, managedActors.Length + 1)
    managedItems = Utility.ResizeFormArray(managedItems, managedItems.Length + 1)
    managedSlotMasks = Utility.ResizeIntArray(managedSlotMasks, managedSlotMasks.Length + 1)
    managedCategories = Utility.ResizeIntArray(managedCategories, managedCategories.Length + 1)
    int newIndex = managedItems.Length - 1
    managedActors[newIndex] = sourceActor
    managedItems[newIndex] = itemForm
    managedSlotMasks[newIndex] = slotMask
    managedCategories[newIndex] = category
EndFunction

bool Function EnsureManagedActorAlias(Actor sourceActor)
    int i = 0
    int emptyAliasIndex = -1
    While i < GetNumAliases()
        ReferenceAlias managedAlias = GetNthAlias(i) as ReferenceAlias
        if managedAlias
            if managedAlias.GetActorReference() == sourceActor
                return true
            elseIf !managedAlias.GetReference() && emptyAliasIndex < 0
                emptyAliasIndex = i
            endIf
        endIf
        i += 1
    EndWhile
    if emptyAliasIndex >= 0
        ReferenceAlias emptyAlias = GetNthAlias(emptyAliasIndex) as ReferenceAlias
        emptyAlias.ForceRefTo(sourceActor)
        return true
    endIf
    Debug.Trace("Mantella Equip could not persist equipment: all managed actor aliases are in use.")
    return false
EndFunction

Function QueueManagedEquipmentRestore(Actor sourceActor)
    EnsureManagedState()
    if !sourceActor || !HasManagedEquipment(sourceActor) || pendingRestoreActors.Find(sourceActor) >= 0
        return
    endIf
    pendingRestoreActors = Utility.ResizeFormArray(pendingRestoreActors, pendingRestoreActors.Length + 1)
    pendingRestoreAttempts = Utility.ResizeIntArray(pendingRestoreAttempts, pendingRestoreAttempts.Length + 1)
    pendingRestoreActors[pendingRestoreActors.Length - 1] = sourceActor
    pendingRestoreAttempts[pendingRestoreAttempts.Length - 1] = 0
    Debug.Trace("Mantella Equip: queued managed restore for " + sourceActor.GetDisplayName())
    ; One event-driven delay lets Skyrim finish default-outfit evaluation and
    ; batches actors that attach together. This does not schedule a polling loop.
    RegisterForSingleUpdate(0.50)
EndFunction

Event OnUpdate()
    EnsureManagedState()
    While pendingRestoreActors.Length > 0
        int lastIndex = pendingRestoreActors.Length - 1
        Actor sourceActor = pendingRestoreActors[lastIndex] as Actor
        int attempt = pendingRestoreAttempts[lastIndex]
        pendingRestoreActors = Utility.ResizeFormArray(pendingRestoreActors, lastIndex)
        pendingRestoreAttempts = Utility.ResizeIntArray(pendingRestoreAttempts, lastIndex)
        ; Fast travel can deliver an alias callback before the actor's 3D and
        ; inventory are available. Never interpret that transient state as an
        ; item having been removed; retry a bounded number of times instead.
        if sourceActor && !sourceActor.Is3DLoaded() && attempt < 3
            pendingRestoreActors = Utility.ResizeFormArray(pendingRestoreActors, pendingRestoreActors.Length + 1)
            pendingRestoreAttempts = Utility.ResizeIntArray(pendingRestoreAttempts, pendingRestoreAttempts.Length + 1)
            pendingRestoreActors[pendingRestoreActors.Length - 1] = sourceActor
            pendingRestoreAttempts[pendingRestoreAttempts.Length - 1] = attempt + 1
            RegisterForSingleUpdate(1.0)
        elseIf sourceActor && sourceActor.Is3DLoaded()
            RestoreManagedEquipment(sourceActor)
        endIf
    EndWhile
EndEvent

Function RestoreManagedEquipment(Actor sourceActor)
    EnsureManagedState()
    if !sourceActor || isRestoringManagedEquipment
        return
    endIf

    bool changed = false
    isRestoringManagedEquipment = true
    restoringActor = sourceActor
    int i = managedItems.Length - 1
    While i >= 0
        if managedActors[i] == sourceActor
            Form itemForm = managedItems[i]
            if !itemForm
                RemoveManagedEntry(i)
                i = managedItems.Length
            elseIf !sourceActor.Is3DLoaded()
                ; Keep the Form-based desired state while Skyrim is unloading
                ; or attaching the actor. Inventory queries are not reliable
                ; during this lifecycle window.
                i = managedItems.Length
            elseIf sourceActor.GetItemCount(itemForm) <= 0
                RemoveManagedEntry(i)
                i = managedItems.Length
            elseIf !sourceActor.IsEquipped(itemForm)
                Debug.Trace("Mantella Equip: restoring managed item " + itemForm.GetName() + " for " + sourceActor.GetDisplayName())
                ReleaseConflictingEquipment(sourceActor, itemForm)
                sourceActor.EquipItem(itemForm, true, true)
                Utility.Wait(0.05)
                if !sourceActor.IsEquipped(itemForm)
                    sourceActor.EquipItemEx(itemForm, 0, true, false)
                    Utility.Wait(0.05)
                endIf
                if sourceActor.IsEquipped(itemForm)
                    changed = true
                    Debug.Trace("Mantella Equip: managed restore verified " + itemForm.GetName() + " for " + sourceActor.GetDisplayName())
                endIf
            else
                Debug.Trace("Mantella Equip: managed item already equipped " + itemForm.GetName() + " for " + sourceActor.GetDisplayName())
            endIf
        endIf
        i -= 1
    EndWhile
    ; Let equip/unequip listener events raised by the silent restore observe the
    ; suppression flag before it is cleared.
    Utility.Wait(0.10)
    restoringActor = None
    isRestoringManagedEquipment = false

    if !HasManagedEquipment(sourceActor)
        ClearManagedActorAlias(sourceActor)
    elseIf changed
        sourceActor.QueueNiNodeUpdate()
        if Conversation && Conversation.IsRunning()
            Conversation.RefreshActorEquipmentState()
        endIf
    endIf
EndFunction

Function ForgetManagedEquipment(Actor sourceActor)
    EnsureManagedState()
    int i = managedItems.Length - 1
    While i >= 0
        if managedActors[i] == sourceActor
            RemoveManagedEntry(i)
        endIf
        i -= 1
    EndWhile
    int pendingIndex = pendingRestoreActors.Find(sourceActor)
    if pendingIndex >= 0
        int lastPendingIndex = pendingRestoreActors.Length - 1
        pendingRestoreActors[pendingIndex] = pendingRestoreActors[lastPendingIndex]
        pendingRestoreAttempts[pendingIndex] = pendingRestoreAttempts[lastPendingIndex]
        pendingRestoreActors = Utility.ResizeFormArray(pendingRestoreActors, lastPendingIndex)
        pendingRestoreAttempts = Utility.ResizeIntArray(pendingRestoreAttempts, lastPendingIndex)
    endIf
    ClearManagedActorAlias(sourceActor)
EndFunction

bool Function IsRestoringEquipmentFor(Actor sourceActor)
    return isRestoringManagedEquipment && restoringActor == sourceActor
EndFunction

bool Function HasManagedEquipment(Actor sourceActor)
    int i = 0
    While i < managedActors.Length
        if managedActors[i] == sourceActor
            return true
        endIf
        i += 1
    EndWhile
    return false
EndFunction

Function ClearManagedActorAlias(Actor sourceActor)
    int i = 0
    While i < GetNumAliases()
        ReferenceAlias managedAlias = GetNthAlias(i) as ReferenceAlias
        if managedAlias && managedAlias.GetActorReference() == sourceActor
            managedAlias.Clear()
            return
        endIf
        i += 1
    EndWhile
EndFunction

Function RemoveManagedEntry(int index)
    int lastIndex = managedItems.Length - 1
    if index < 0 || index > lastIndex
        return
    endIf
    if index != lastIndex
        managedActors[index] = managedActors[lastIndex]
        managedItems[index] = managedItems[lastIndex]
        managedSlotMasks[index] = managedSlotMasks[lastIndex]
        managedCategories[index] = managedCategories[lastIndex]
    endIf
    managedActors = Utility.ResizeFormArray(managedActors, lastIndex)
    managedItems = Utility.ResizeFormArray(managedItems, lastIndex)
    managedSlotMasks = Utility.ResizeIntArray(managedSlotMasks, lastIndex)
    managedCategories = Utility.ResizeIntArray(managedCategories, lastIndex)
EndFunction

int Function GetManagedCategory(Form itemForm)
    if itemForm as Armor
        return MANAGED_ARMOR
    elseIf itemForm as Weapon
        return MANAGED_WEAPON
    elseIf itemForm as Ammo
        return MANAGED_AMMO
    endIf
    return 0
EndFunction

int Function GetManagedSlotMask(Form itemForm)
    Armor armorItem = itemForm as Armor
    if armorItem
        return armorItem.GetSlotMask()
    endIf
    return 0
EndFunction

bool Function ManagedEntriesConflict(int newCategory, int newMask, int oldCategory, int oldMask)
    if newCategory != oldCategory
        return false
    endIf
    if newCategory == MANAGED_ARMOR
        return Math.LogicalAnd(newMask, oldMask) != 0
    endIf
    return true
EndFunction

Function ReleaseConflictingEquipment(Actor sourceActor, Form requestedItem)
    Armor requestedArmor = requestedItem as Armor
    if requestedArmor
        int requestedMask = requestedArmor.GetSlotMask()
        int slot = 30
        While slot <= 61
            int slotMask = Armor.GetMaskForSlot(slot)
            if Math.LogicalAnd(requestedMask, slotMask) != 0
                Armor equippedArmor = sourceActor.GetEquippedArmorInSlot(slot)
                if equippedArmor && equippedArmor != requestedArmor
                    UnequipForReplacement(sourceActor, equippedArmor)
                endIf
            endIf
            slot += 1
        EndWhile
        return
    endIf

    Weapon requestedWeapon = requestedItem as Weapon
    if requestedWeapon
        Weapon rightWeapon = sourceActor.GetEquippedWeapon(false)
        if rightWeapon && rightWeapon != requestedWeapon
            UnequipForReplacement(sourceActor, rightWeapon)
        endIf
        Weapon leftWeapon = sourceActor.GetEquippedWeapon(true)
        if leftWeapon && leftWeapon != requestedWeapon
            UnequipForReplacement(sourceActor, leftWeapon)
        endIf
    endIf
EndFunction

Function UnequipForReplacement(Actor sourceActor, Form itemForm)
    sourceActor.UnequipItem(itemForm, false, true)
    Utility.Wait(0.02)
    if sourceActor.IsEquipped(itemForm)
        sourceActor.UnequipItemEx(itemForm, 0, false)
        Utility.Wait(0.02)
    endIf
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
                if StringUtil.Find(normalizedInventoryName, normalizedRequest) >= 0
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

bool Function IsGenericShieldRequest(string normalizedRequest)
    return normalizedRequest == "shield" || normalizedRequest == "best shield" || normalizedRequest == "your shield"
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

Armor Function FindBestShield(Actor sourceActor)
    Armor bestShield = None
    int bestRating = -1
    int itemCount = sourceActor.GetNumItems()
    int i = 0
    int shieldMask = Armor.GetMaskForSlot(41)
    While i < itemCount
        Armor armorItem = sourceActor.GetNthForm(i) as Armor
        if armorItem && sourceActor.GetItemCount(armorItem) > 0 && Math.LogicalAnd(armorItem.GetSlotMask(), shieldMask) != 0
            int armorRating = armorItem.GetArmorRating()
            if armorRating > bestRating
                bestRating = armorRating
                bestShield = armorItem
            endIf
        endIf
        i += 1
    EndWhile
    return bestShield
EndFunction
