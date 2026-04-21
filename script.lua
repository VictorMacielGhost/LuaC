g_Character = 
{
    name        =  "Steve",
    health      =   100,
    position    =   { positionName = "Bedroom", positionID = 0xA1 },
    inventory   =   {  }
}

g_KeyItems = 
{
    { itemName = "Bathroom Key", itemID = 0xB1 },
    { itemName = "Picklock from a Toolbox", itemID = 0xB2 },
}

g_Positions = 
{ 
    { positionName = "Bedroom",         positionID = 0xA1,  allowed = false,     locked = false, hasToBeAt = { 0xA2 } },
    { positionName = "Living Room",     positionID = 0xA2,  allowed = false,     locked = false, hasToBeAt = { 0xA1, 0xA3, 0xA4, 0xA5 } },
    { positionName = "Kitchen",         positionID = 0xA3,  allowed = false,     locked = false, hasToBeAt = { 0xA2 } }, 
    { positionName = "Bathroom",        positionID = 0xA4,  allowed = false,     locked = true,  hasToBeAt = { 0xA2 }, keyItem = g_KeyItems[1] }, 
    { positionName = "Garage",          positionID = 0xA5,  allowed = false,     locked = false, hasToBeAt = { 0xA2 } },
    { positionName = "Outside Home",    positionID = 0xA6,  allowed = false,     locked = true, hasToBeAt = { 0xA4 }, keyItem = g_KeyItems[2] },
}

g_Actions = 
{
    { id = 1, name = "Open Inventory",          func = function() openInventory(g_Character) end,                   allowed = true },
    { id = 2, name = "Move to",                 func = function() moveCharacter(g_Character) end,                   allowed = true },
    { id = 3, name = "Take Item",               func = function() takeItem(g_Character) end,                                       },
    { id = 4, name = "Print Character Status",  func = function() printCharacterStatus(g_Character) end,            allowed = true },
    { id = 5, name = "Drop Item",               func = function() dropItem(g_Character) end,                                       },
    { id = 6, name = "Finish game",             func = function() action = nil end,                                 allowed = false},
}

g_Items = 
{
    { itemName = "Bathroom Key", positionID = 0xA2 },
    { itemName = "Picklock from a Toolbox", positionID = 0xA5 },
}

g_PlayInfo = 
{
    movedTimes = 0,
    startedTime = os.time(),
    actionsPerformed = 0,
}

MAX_INVENTORY_SIZE = 1

function print(message)
    io.write(message .. "\n")
end

function printCharacterStatus(character)
    print("Character Status:")
    print("Name: " .. character.name)
    print("Health: " .. character.health)
    print("Current Position: " .. character.position.positionName)
end

function moveCharacter(character)

    print("Select somewhere to move to or press 0 to cancel: ")
    for i = 1, #g_Positions do
        if g_Positions[i].hasToBeAt ~= nil then
            for j = 1, #g_Positions[i].hasToBeAt do
                if character.position.positionID == g_Positions[i].hasToBeAt[j] then
                    g_Positions[i].allowed = true
                    break
                else
                    g_Positions[i].allowed = false
                end
            end
            if g_Positions[i].allowed then
                print("[" .. i .. "] " .. g_Positions[i].positionName)
            end
        end
    end

    local newPosition = io.read("*n")
    local hasKey = false
    local positionId = newPosition

    if(newPosition == 0) then
        print("Move action cancelled.")
        return
    end

    local newPosition = g_Positions[newPosition]
    
    if(newPosition.positionID == newPosition.positionID and newPosition.allowed) then
        if(newPosition.locked) then
            
            for j = 1, #character.inventory do
                if(character.inventory[j] == newPosition.keyItem.itemName) then
                    hasKey = true
                    break
                end
            end

            if not hasKey then
                print("The " .. newPosition.positionName .. " is locked. You need the " .. newPosition.keyItem.itemName .. " to enter.")
                return
            end

            print(character.name .. " used the " .. newPosition.keyItem.itemName .. " to unlock the " .. newPosition.positionName)
            g_Positions[positionId].locked = false

        end

        character.position = newPosition
        print(character.name .. " moved to the " .. character.position.positionName)

        if(newPosition.positionID == 0xA6) then
            for i = 1, #g_Actions do
                g_Actions[i].allowed = false -- Disable all actions except "Finish game"
            end
            g_Actions[6].allowed = true -- Enable "Finish game" action
        end

        local itemsFound = {}
        for i = 1, #g_Items do

            if g_Items[i].positionID == newPosition.positionID then
                itemsFound[#itemsFound + 1] = g_Items[i]
            end
        end

        if #itemsFound == 0 then
            g_Actions[3].allowed = false -- Disable "Take Item" action
            return
        end

        if #itemsFound > 1 then
            local str = "You see a " .. itemsFound[1].itemName .. " and a "
            for j = 2, #itemsFound do
                str = str .. itemsFound[j].itemName 
                if j < #itemsFound then
                    str = str .. " and a "
                end
            end
            print(str .. " here.")
        elseif #itemsFound == 1 then
            print("You see a " .. itemsFound[1].itemName .. " here.")
        end

        g_Actions[3].allowed = true -- Enable "Take Item" action

    else
        print(character.name .. " cannot move to the " .. newPosition.positionName)
        return
    end
end

function openInventory(character)
    print(character.name .. "'s Inventory:")

    if #character.inventory == 0 or ( #character.inventory == 1 and character.inventory[1] == nil ) then
        print("Inventory is empty.")
        print("\a")
        return
    end

    for i = 1, #character.inventory do
        print("[" .. i .. "]" .. ": " .. (character.inventory[i] or "Empty"))
    end
    print("\a")
end

function performAction(actionID)
    for i = 1, #g_Actions do
        if(g_Actions[i].id == actionID and g_Actions[i].allowed == true) then
            g_Actions[i].func()
            return
        end
    end
    print("Action with ID " .. actionID .. " not found or not allowed.")
end

function printAvailableActions()
    print("Available Actions:")
    for i = 1, #g_Actions do
        if(g_Actions[i] ~= nil and g_Actions[i].allowed == true) then
            print("[" .. g_Actions[i].id .. "] " .. g_Actions[i].name)
        end
    end
end

function takeItem(character)

    if #character.inventory >= MAX_INVENTORY_SIZE then
        print(character.name .. "'s inventory is full. Cannot take more items. Drop an item before picking up new ones.")
        return
    end

    local itemsToPickup = {}
    local selectedItem

    for i = 1, #g_Items do
        if g_Items[i].positionID == character.position.positionID then
            itemsToPickup[#itemsToPickup + 1] = { g_Items[i], i}
        end
    end

    if #itemsToPickup == 0 then
        print("There are no items to pick up here.")
        return
    end

    if #itemsToPickup > 1 then
        print("Multiple items available to pick up. Select an item or enter 0 to cancel pick up:")
        for i = 1, #itemsToPickup do
            print("[" .. i .. "] " .. itemsToPickup[i][1].itemName)
        end

        local itemIndex = io.read("*n")
        if itemIndex < 1 or itemIndex > #itemsToPickup then
            print("Invalid item index. Take action cancelled.")
            return
        else
            selectedItem = itemsToPickup[itemIndex]
        end
    else
        selectedItem = itemsToPickup[1]
        g_Actions[3].allowed = false -- Disable "Take Item" action if no more items are left after this one
    end

    for i = 1, MAX_INVENTORY_SIZE do
        if character.inventory[i] == nil then
            character.inventory[#character.inventory + 1] = selectedItem[1].itemName
            break
        end
    end

    print(character.name .. " took the " .. selectedItem[1].itemName)
    g_Items[selectedItem[2]].positionID = nil
    g_Actions[5].allowed = true -- Enable "Drop Item" action

end

function dropItem(character)
    if #character.inventory == 0 or ( #character.inventory == 1 and character.inventory[1] == "Empty" ) then
        print(character.name .. "'s inventory is empty. Nothing to drop.")
        return
    end

    print("Select an item to drop or enter 0 to cancel:")
    openInventory(character);

    local itemIndex = io.read("*n")
    if itemIndex < 1 or itemIndex > #character.inventory then
        print("Invalid item index. Drop action cancelled.")
        return
    end
    
    if character.inventory[itemIndex] == "Empty" or character.inventory[itemIndex] == nil then
        print("Cannot drop an empty slot. Drop action cancelled.")
        return
    end

    local droppedItem = character.inventory[itemIndex]
    table.remove(character.inventory, itemIndex)
    print(character.name .. " dropped the " .. droppedItem)
    g_Items[#g_Items + 1] = { itemName = droppedItem, positionID = character.position.positionID }
    g_Actions[3].allowed = true -- Enable "Take Item" action

    if #character.inventory == 0 or ( #character.inventory == 1 and character.inventory[1] == "Empty" ) then
        g_Actions[5].allowed = false -- Disable "Drop Item" action
    end

end

print("You're a ten year old child")
print("You woke up in a bedroom which you're not familiar with.")
print("You need to find a way to get out of this house.")
print("\n")

printCharacterStatus(g_Character)
printAvailableActions()

action = io.read("*n")
while action do

    if(g_Character.position.positionID == 0xA6) then
        print("Congratulations! You have successfully escaped the house!")
        print("Tho you may not remember how you got here, you feel a sense of relief as you step outside into the fresh air.")
        print("Thank you for playing!")

        print("")
        print("Game Summary:")
        print("Total actions performed: " .. g_PlayInfo.actionsPerformed)
        print("Total moves made: " .. g_PlayInfo.movedTimes)
        print("Time taken: " .. os.difftime(os.time(), g_PlayInfo.startedTime) .. " seconds")

        io.read()
        io.read("*n")
        local tst = io.read("*n")
        break
    end

    performAction(action)
    g_PlayInfo.actionsPerformed = g_PlayInfo.actionsPerformed + 1
    if(action == 2) then
        g_PlayInfo.movedTimes = g_PlayInfo.movedTimes + 1
    end
    printAvailableActions()
    action = io.read("*n")
end