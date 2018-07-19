---------------------------
-- ccScript 0.7.0 by Texafornian
--
-- Requires "ccConfig.lua" in /scripts/ folder!
-- Requires "ladderlist.json" in /data/ folder!
--
-- Many thanks to:
-- * ppsychrite
-- * Reinhart
-- * Mupf
-- * Atkana

------------------
-- DO NOT TOUCH!
------------------

require("ccConfig")
ccAdvanceQuests = require("ccAdvanceQuests")
ccHardcore = require("ccHardcore")
ccPerks = require("ccPerks")

axeWeaponTable = {}
bluntWeaponTable = {}
itemsTable = {}
longWeaponTable = {}
marksmanAmmoTable = {}
marksmanWeaponTable = {}
pantsTable = {}
punishIntTable = {}
punishExtTable = {}
raceTable = {}
safeCellsTable = {}
shirtTable = {}
skirtTable = {}
shoesTable = {}
shortWeaponTable = {}
spawnTable = {}
spearWeaponTable = {}

local ccSettings = {}

ccSettings.windowDeleteChar = 81001
ccSettings.windowLadder = 81002
ccSettings.windowMOTD = 81003

------------------
-- METHODS SECTION
------------------

local ccScript = {}

math.randomseed( os.time() )

ccScript.Bounty = function (pid, pid2, num)

    if myMod.CheckPlayerValidity(pid, pid2) then
        tes3mp.SetBounty(pid2, num)
        tes3mp.SendBounty(pid2)
        Players[pid2]:SaveBounty()

        tes3mp.SendMessage(pid, color.Yellow .. "Setting player " .. pid2 .. "'s bounty to " .. num .. "." .. color.Default .. "\n", false)
        tes3mp.SendMessage(pid2, color.Yellow .. "Your bounty has been changed to " .. num .. "." .. color.Default .. "\n", false)
    end
end

ccScript.Coords = function(pid)
    tes3mp.LogMessage(2,"++++ " .. tes3mp.GetExteriorX(pid) .. ", " .. tes3mp.GetExteriorY(pid) .. ", " .. tes3mp.GetPosX(pid) .. ", " .. tes3mp.GetPosY(pid) .. ", " .. tes3mp.GetPosZ(pid) .. ", " .. tes3mp.GetRotZ(pid) .. ", " .. "\n")
end

ccScript.DeleteCharacter = function(pid)
    local playerName = string.lower(Players[pid].name)
    local playerNameLC = string.lower(Players[pid].data.login.name)

    tes3mp.LogMessage(2, "++++ " .. playerName .. " has called ccScript.DeleteCharacter ++++")

    if Players[pid].data.hardcoreMode then -- Ensure that player is removed from HC ladder if applicable

        if ccConfig.hardcoreEnabled == true and ccHardcore.LadderExists() == true then
            local hcLadder = "ladder_" .. os.date("%y%m")

            if ladderList.players[playerNameLC] then
                tes3mp.LogMessage(2, "++++ Removing player " .. playerName .. " from the ladder file ++++")
                ladderList.players[playerNameLC] = nil
                jsonInterface.save( hcLadder .. ".json", ladderList)
            end
        end
    end

    -- Thanks to mupf for this approach
    os.remove(ccConfig.playerPath .. Players[pid].data.login.name .. ".json")
    Players[pid]:Kick()
    tes3mp.LogMessage(2, "++++ " .. playerName .. " has been deleted ++++")
end

ccScript.DeleteCharWindow = function(pid)
    local deleteText = "Are you sure you wish to delete your character?\n\
    This can't be undone! If you choose Yes, then you will be kicked and your character will be deleted from the server.\n\
    You'll be able to make a new character with your old name upon reconnecting, if you wish, but you'll lose your tokens in the process."
    tes3mp.CustomMessageBox(pid, ccSettings.windowDeleteChar, deleteText, "Yes;No")
end

-- Displays the server MOTD after chargen if enabled in ccConfig
ccScript.MOTD = function(pid)
    
    if ccConfig.hardcoreEnabled == true then
        tes3mp.CustomMessageBox(pid, ccSettings.windowMOTD, ccMOTD.generated, "Yes;No")
    else
        tes3mp.CustomMessageBox(pid, ccSettings.windowMOTD, ccMOTD.generated, "Ok")
    end
end

ccScript.OnGUIAction = function(pid, idGui, data)
    local pick = tonumber(data)

    if idGui == ccSettings.windowDeleteChar then

        if pick == 0 then -- Delete character
            ccScript.DeleteCharacter(pid)
        end
        return true
    elseif idGui == ccSettings.windowMOTD then

        -- Yes to HC Mode
        if ccConfig.hardcoreEnabled == true and pick == 0 then
            ccHardcore.HardcoreMode(pid)
        end
        return true
    end

    -- If no match above, then compare against ccPerks' OnGuiAction
    if ccConfig.perksEnabled == true then

        if ccPerks.OnGUIAction(pid, idGui, data) then return
        else return false
        end
    else return false
    end
end

-- Update time played on server and save stats
ccScript.OnPlayerCellChange = function(pid)

    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        Players[pid]:SaveCell()
        Players[pid]:SaveStatsDynamic()

        if Players[pid].data.timeKeeping then
            local played = Players[pid].data.timeKeeping.timePlayed
            local stored = Players[pid].data.timeKeeping.timeStored

            Players[pid].data.timeKeeping.timePlayed = played + (os.time() - stored)
            Players[pid].data.timeKeeping.timeStored = os.time()
        end

        tes3mp.LogMessage(1, "Saving player " .. pid)
        Players[pid]:Save()
    end
end

-- Checks whether player had Hardcore mode enabled
ccScript.OnPlayerDeath = function(pid)

    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then

        -- Player has the hardcoreMode table in their json file...
        if ccConfig.hardcoreEnabled == true and Players[pid].data.hardcoreMode and Players[pid].data.hardcoreMode.enabled == 1 then

            -- Player died in a safe cell
            if ccSafeCells.enabled == true and ccHardcoreSettings.useSafeCells == true and checkSafeCell(pid) == true then
                Players[pid]:ProcessDeath()
            else

                -- Clear player's tokenlist entry if ccPerks is enabled
                if ccConfig.perksEnabled == true then
                    ccPerks.ProcessHCDeath(pid)
                end

                ccHardcore.ProcessDeath(pid)
            end

        -- Player was created after the hardcore mode update
        else
            Players[pid]:ProcessDeath()
        end
    end
end

-- Run spawn and inventory randomizer right after chargen
ccScript.OnPlayerEndCharGen = function(pid)

    if Players[pid] ~= nil then
        Players[pid]:EndCharGen()

        local hcInfo = {}
        local timeInfo = {}

        hcInfo.enabled = 0
        hcInfo.ladder = os.date("%y%m")

        timeInfo.timeCreated = os.time()
        timeInfo.timeStored = os.time()
        timeInfo.timePlayed = 0

        Players[pid].data.hardcoreMode = hcInfo
        Players[pid].data.timeCapsule = 0
        Players[pid].data.timeKeeping = timeInfo

        Players[pid]:Save()

        ccScript.SpawnPosition(pid)
        ccScript.SpawnItems(pid)
    end
end

-- Save Hardcore player level-ups to ladder
ccScript.OnPlayerLevel = function(pid)
    local playerName = Players[pid].name
    local playerNameLC = string.lower(playerName)

    if ccConfig.perksEnabled == true then
        ccPerks.ProcessLevelUp(pid)
    end

    if ccConfig.hardcoreEnabled == true and ccHardcore.LadderExists() == true then
        local hcLadder = "ladder_" .. os.date("%y%m")

        if ladderList.players[playerNameLC] then
            tes3mp.LogMessage(2, "++++ Updating ladder level of player " .. playerName .. " ++++")
            ladderList.players[playerNameLC].level = Players[pid].data.stats.level
            jsonInterface.save( hcLadder .. ".json", ladderList)
        end
    end
end

-- Used to report days, hours, minutes since some given timestamp
ccScript.ParseTime = function(timeCurrent, timeOriginal, ident)
    -- Thanks to jsmorley at https://forum.rainmeter.net/viewtopic.php?t=23486
    local diff = 0

    if ident == 1 then
        diff = (timeCurrent - timeOriginal)
    elseif ident == 2 then
        diff = timeCurrent
    end

    local diffDays = math.floor(diff / 86400)
    local remainder = diff % 86400
    local diffHours = math.floor(remainder / 3600)
    local remainder = remainder % 3600
    local diffMinutes = math.floor(remainder / 60)

    return diffDays, diffHours, diffMinutes
end

-- Iterates through entries of an info table { a source table, a destination table } to place source into destination
ccScript.PopulateTable = function(infoTable)

    for index, value in ipairs(infoTable) do

        for index2, value2 in ipairs(infoTable[index][1]) do
            table.insert(infoTable[index][2], value2)
        end
    end
end

-- Used to send a player into a cell with no doors
ccScript.PunishCell = function(pid, targetPID)

    if #punishIntTable == 0 then
        local message = color.Red .. "You must enter at least one cell in ccConfig.lua's ccPunish.Vanilla.Interiors table.\n"
        tes3mp.SendMessage(pid, message, false)
        return false
    end

    if myMod.CheckPlayerValidity(pid, targetPID) then
        local targetPlayerName = Players[tonumber(targetPID)].name
        local rando = math.random(1, #punishIntTable)

        tes3mp.SetCell(targetPID, punishIntTable[rando][1])
        tes3mp.SendCell(targetPID)

        local message = color.Orange .. "SERVER: " .. targetPlayerName .. " has been sent to an alternate dimension.\n"
        tes3mp.SendMessage(pid, message, true)
    end
end

-- Used to send a player into the ocean
ccScript.PunishOcean = function(pid, targetPID)

    if #punishExtTable == 0 then
        local message = color.Red .. "You must enter at least one cell in ccConfig.lua's ccPunish.Vanilla.Exteriors table.\n"
        tes3mp.SendMessage(pid, message, false)
        return false
    end

    if myMod.CheckPlayerValidity(pid, targetPID) then
        local targetPlayerName = Players[tonumber(targetPID)].name
        local rando = math.random(1, #punishExtTable)

        tes3mp.SetCell(targetPID, punishExtTable[rando][1])
        tes3mp.SendCell(targetPID)

        tes3mp.SetPos(targetPID, punishExtTable[rando][2], punishExtTable[rando][3], punishExtTable[rando][4])
        tes3mp.SetRot(targetPID, 0, punishExtTable[rando][5])
        tes3mp.SendPos(targetPID)

        local message = color.Orange .. "SERVER: " .. targetPlayerName .. " is going for a swim.\n"
        tes3mp.SendMessage(pid, message, true)
    end
end

-- Used to roll the dice
ccScript.Roll = function(pid)
    local cellDescription = Players[pid].data.location.cell
    local rando = math.random(0, 100)

    if myMod.IsCellLoaded(cellDescription) == true then

        for index, visitorPid in pairs(LoadedCells[cellDescription].visitors) do

            local playerName = tes3mp.GetName(pid)
            local message = color.LightPink .. playerName .. " (" .. pid .. ") rolls " .. rando .. ".\n"
            tes3mp.SendMessage(visitorPid, message, false)
        end
    end
end

-- Populates items table that stores all items that new players receive after chargen
ccScript.SetupInventory = function()
    tes3mp.LogMessage(2, "Populating inventory tables with vanilla entries")

    local infoTableVanilla = {
        { ccSpawn.Vanilla.Items, itemsTable },
        { ccSpawn.Vanilla.Pants, pantsTable },
        { ccSpawn.Vanilla.Shirts, shirtTable },
        { ccSpawn.Vanilla.Skirts, skirtTable },
        { ccSpawn.Vanilla.Shoes, shoesTable }
    }

    ccScript.PopulateTable(infoTableVanilla)

    if string.lower(ccConfig.serverPlugins) == "tamriel" then -- TCC Tamriel
        tes3mp.LogMessage(2, "Populating inventory tables with Tamriel entries")

        local infoTableTamriel = {
            { ccSpawn.Tamriel.Items, itemsTable },
            { ccSpawn.Tamriel.Pants, pantsTable },
            { ccSpawn.Tamriel.Shirts, shirtTable },
            { ccSpawn.Tamriel.Skirts, skirtTable },
            { ccSpawn.Tamriel.Shoes, shoesTable }
        }

        ccScript.PopulateTable(infoTableTamriel)
    end
end

-- Creates MOTD message based on ccConfig settings
ccScript.SetupMOTD = function()
    tes3mp.LogMessage(2, "Generating MOTD")

    ccMOTD.generated = ccMOTD.message

    if ccConfig.hardcoreEnabled == true then
        ccMOTD.generated = ccMOTD.generated .. "\n" .. ccMOTD.messageHC
    end
end

-- Populates cell tables for punish command
ccScript.SetupPunish = function()
    tes3mp.LogMessage(2, "Populating punish cell tables")

    local infoTableVanilla = {
        { ccPunish.Vanilla.Interiors, punishIntTable },
        { ccPunish.Vanilla.Exteriors, punishExtTable }
    }

    ccScript.PopulateTable(infoTableVanilla)

    if string.lower(ccConfig.serverPlugins) == "tamriel" then -- TCC Tamriel
        tes3mp.LogMessage(2, "Populating punish cell tables with Tamriel entries")

        local infoTableTamriel = {
            { ccPunish.Tamriel.Interiors, punishIntTable },
            { ccPunish.Tamriel.Exteriors, punishExtTable }
        }

        ccScript.PopulateTable(infoTableTamriel)
    end
end

-- Populates safe cells table for player deaths without consequences
ccScript.SetupSafeCells = function()
    tes3mp.LogMessage(2, "Populating safe cells table with spawn table entries")

    -- Add all spawn cells to safe cells table if enabled in ccConfig.lua
    if ccSafeCells.useSpawnCells == true then

        for index, entryData in pairs(spawnTable) do
            local tableEntry = { spawnTable[index][1] }
            table.insert(safeCellsTable, tableEntry)
        end
    end

    tes3mp.LogMessage(2, "Populating safe cells table with additional vanilla entries")

    -- Add additional cells to safe cells table
    local infoTableVanilla = {
        { ccSafeCells.Vanilla, safeCellsTable }
    }
    
    ccScript.PopulateTable(infoTableVanilla)

    if string.lower(ccConfig.serverPlugins) == "tamriel" then -- TCC Tamriel
        tes3mp.LogMessage(2, "Populating safe cells table with additional Tamriel entries")

        local infoTableTamriel = {
            { ccSafeCells.Tamriel, safeCellsTable }
        }
        
        ccScript.PopulateTable(infoTableTamriel)
    end
end

-- Populates spawn table (and warp table) for randomized spawns
ccScript.SetupSpawns = function()
    tes3mp.LogMessage(2, "Populating spawn table with vanilla entries")

    for index, spawnData in ipairs(ccSpawn.Vanilla.Cells) do
        table.insert(spawnTable, spawnData)
    end

    if string.lower(ccConfig.serverPlugins) == "tamriel" then -- TCC Tamriel
        tes3mp.LogMessage(2, "Populating spawn table with Tamriel entries")

        for index, spawnData in ipairs(ccSpawn.Tamriel.Cells) do
            table.insert(spawnTable, spawnData)
        end
    end
end

-- Runs all cc modules to setup server data (if enabled)
ccScript.SetupSuite = function()
    ccScript.SetupMOTD()
    ccScript.SetupInventory()
    ccScript.SetupPunish()
    ccScript.SetupSpawns()
    ccScript.SetupSafeCells()
    ccScript.SetupWeapons()

    if ccConfig.advanceQuestsEnabled == true then
        ccAdvanceQuests.CheckTime()
    end

    if ccConfig.hardcoreEnabled == true then
        ccHardcore.SetupDeathDrop()

        if ccHardcore.LadderCheck() == true then
            LoadLadderList()
        end
    end

    if ccConfig.perksEnabled == true then
        ccPerks.SetupCreatures()
        ccPerks.SetupLottery()
        ccPerks.SetupRaces()
        ccPerks.SetupWarp()
        LoadTokenList()
        ccPerks.TokenClean()
    end
end

-- Populates items table that stores all items that new players receive after chargen
ccScript.SetupWeapons = function()
    tes3mp.LogMessage(2, "Populating weapon tables with vanilla entries")

    local infoTableVanilla = {
        { ccSpawn.Vanilla.Axes, axeWeaponTable },
        { ccSpawn.Vanilla.BluntWeapons, bluntWeaponTable },
        { ccSpawn.Vanilla.Longblades, longWeaponTable },
        { ccSpawn.Vanilla.MarksmanAmmo, marksmanAmmoTable },
        { ccSpawn.Vanilla.MarksmanWeapons, marksmanWeaponTable },
        { ccSpawn.Vanilla.Shortblades, shortWeaponTable },
        { ccSpawn.Vanilla.Spears, spearWeaponTable }
    }

    ccScript.PopulateTable(infoTableVanilla)

    if string.lower(ccConfig.serverPlugins) == "tamriel" then -- TCC Tamriel
        tes3mp.LogMessage(2, "Populating weapon tables with Tamriel entries")

        local infoTableTamriel = {
            { ccSpawn.Tamriel.Axes, axeWeaponTable },
            { ccSpawn.Tamriel.BluntWeapons, bluntWeaponTable },
            { ccSpawn.Tamriel.Longblades, longWeaponTable },
            { ccSpawn.Tamriel.MarksmanAmmo, marksmanAmmoTable },
            { ccSpawn.Tamriel.MarksmanWeapons, marksmanWeaponTable },
            { ccSpawn.Tamriel.Shortblades, shortWeaponTable },
            { ccSpawn.Tamriel.Spears, spearWeaponTable }
        }

        ccScript.PopulateTable(infoTableTamriel)
    end
end

-- Give players all items listed in ccConfig and randomize set of clothes
ccScript.SpawnItems = function(pid)
    local item = {}
    local rando = 1
    local race = string.lower(Players[pid].data.character.race)

    math.random(); math.random() -- Try to improve RNG

    Players[pid].data.inventory = {}
    Players[pid].data.equipment = {}

    tes3mp.LogMessage(2, "++++ Adding items to new character ++++")
    
    -- Add all ccSpawn.__.Items from ccConfig to player's inventory
    for index, entryData in pairs(itemsTable) do
        item = { refId = itemsTable[index][1], count = itemsTable[index][2], charge = itemsTable[index][3] }
        table.insert(Players[pid].data.inventory, item)
    end

    tes3mp.LogMessage(2, "++++ Randomizing new player's clothes ++++")

    -- Give player random shoes from ccConfig if applicable
    if race ~= "argonian" and race ~= "khajiit" and race ~= "t_els_cathay-raht" and race ~= "t_els_ohmes-raht" then
        rando = math.random(1, #shoesTable)
        item = { refId = shoesTable[rando][1], count = shoesTable[rando][2], charge = shoesTable[rando][3] }
        Players[pid].data.equipment[7] = item
    end

    -- Give player a random shirt from ccConfig
    rando = math.random(1, #shirtTable)
    item = { refId = shirtTable[rando][1], count = shirtTable[rando][2], charge = shirtTable[rando][3] }
    Players[pid].data.equipment[8] = item

    -- Give player random legwear from ccConfig
    if Players[pid].data.character.gender == 1 then
        rando = math.random(1, #pantsTable)
        item = { refId = pantsTable[rando][1], count = pantsTable[rando][2], charge = pantsTable[rando][3] }
        Players[pid].data.equipment[9] = item
    else
        rando = math.random(1, #skirtTable)
        item = { refId = skirtTable[rando][1], count = skirtTable[rando][2], charge = skirtTable[rando][3] }
        Players[pid].data.equipment[10] = item
    end

    -- Give player a random starting weapon if applicable
    if ccSpawn.giveStartingWeapon == true then
        checkWeaponSkills(pid)
    end

    -- Refresh inventory
    Players[pid]:LoadInventory()
    Players[pid]:LoadEquipment()
end

-- Randomized spawn position based on global spawnTable in server.lua
ccScript.SpawnPosition = function(pid)
    math.random(); math.random() -- Try to improve RNG
    local tempRef = math.random(1, #spawnTable) -- Pick a random value from the spawn table

    tes3mp.LogMessage(2, "++++ Spawning new player in cell ... ++++")
    tes3mp.LogMessage(2, "++++ (" .. spawnTable[tempRef][1] .. ") ++++")
    tes3mp.SetCell(pid, spawnTable[tempRef][1])
    tes3mp.SendCell(pid)
    tes3mp.SetPos(pid, spawnTable[tempRef][2], spawnTable[tempRef][3], spawnTable[tempRef][4])
    tes3mp.SetRot(pid, 0, spawnTable[tempRef][5])
    tes3mp.SendPos(pid)
end

-- Calculates how long a player has been on the server + playtime
ccScript.TimeOnServer = function(pid)
    local diffDays = 0
    local diffHours = 0
    local diffMinutes = 0
    local timeCurrent = os.time()
    local timeCreated = Players[pid].data.timeKeeping.timeCreated
    local timePlayed = Players[pid].data.timeKeeping.timePlayed

    diffDays, diffHours, diffMinutes = ccScript.ParseTime(timeCurrent, timeCreated, 1)
    tes3mp.SendMessage(pid, color.Yellow .. "Your character was created " .. diffDays .. " day(s), " .. diffHours .. " hour(s), " .. diffMinutes .. " minute(s) ago.\n", false)

    diffDays, diffHours, diffMinutes = ccScript.ParseTime(timePlayed, nil, 2)
    tes3mp.SendMessage(pid, color.Yellow .. "You've played for " .. diffDays .. " day(s), " .. diffHours .. " hour(s), " .. diffMinutes .. " minute(s).\n", false)
end

--------------------
-- FUNCTIONS SECTION
--------------------

-- Returns true if a player died in a safe cell (ccConfig.lua)
function checkSafeCell(pid)
    local deathCell = tes3mp.GetCell(pid)

    for index, cellName in pairs(safeCellsTable) do

        if deathCell == string.lower(safeCellsTable[index][1]) then
            return true
        end
    end

    return false
end

-- Check a player's weapon skills for weapon randomization after chargen
function checkWeaponSkills(pid)
    tes3mp.LogMessage(2, "++++ Checking player weapon skills ++++")
    math.random(); math.random() -- Try to get better RNG

    if Players[pid].data.skills.Axe >= ccSpawn.startingWeaponMinLevel then
        local rando = math.random(1, #axeWeaponTable)
        giveEquipment(pid, rando, axeWeaponTable, 16)
    elseif Players[pid].data.skills.Bluntweapon >= ccSpawn.startingWeaponMinLevel then
        local rando = math.random(1, #bluntWeaponTable)
        giveEquipment(pid, rando, bluntWeaponTable, 16)
    elseif Players[pid].data.skills.Longblade >= ccSpawn.startingWeaponMinLevel then
        local rando = math.random(1, #longWeaponTable)
        giveEquipment(pid, rando, longWeaponTable, 16)
    elseif Players[pid].data.skills.Marksman >= ccSpawn.startingWeaponMinLevel then
        local rando = math.random(1, #marksmanWeaponTable)
        giveEquipment(pid, rando, marksmanWeaponTable, 16)

        rando = math.random(1, #marksmanAmmoTable)
        giveEquipment(pid, rando, marksmanAmmoTable, 18)
    elseif Players[pid].data.skills.Shortblade >= ccSpawn.startingWeaponMinLevel then
        local rando = math.random(1, #shortWeaponTable)
        giveEquipment(pid, rando, shortWeaponTable, 16)
    elseif Players[pid].data.skills.Spear >= ccSpawn.startingWeaponMinLevel then
        local rando = math.random(1, #spearWeaponTable)
        giveEquipment(pid, rando, spearWeaponTable, 16)
    end
end

-- Give player an item that is automatically equipped
function giveEquipment(pid, index, sourceTable, position)
    tes3mp.LogMessage(2, "++++ ccScript.giveEquipment called ++++")
    local equipEntry = { refId = sourceTable[index][1], count = sourceTable[index][2], charge = sourceTable[index][3] }
    Players[pid].data.equipment[position] = equipEntry
end

return ccScript