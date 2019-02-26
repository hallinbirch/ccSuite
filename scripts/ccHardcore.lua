---------------------------
-- ccHardcore 0.7.0 by Texafornian
--
-- Requires "ccConfig.lua" in /scripts/ folder!
-- Requires "ccHardcoreSettings.lua" in /scripts/ folder!
--
-- Many thanks to:
-- * Mupf

------------------
-- DO NOT TOUCH!
------------------

require("ccsuite/ccConfig")
require("ccsuite/ccHardcoreConfig")
require("config")

deathDropTable = {}
ladderList = {}

local ccSettings = {}

ccSettings.currentLadder = ""
ccSettings.windowLadder = 81200

------------------
-- METHODS SECTION
------------------

local ccHardcore = {}

-- Initializes ladder table
ccHardcore.LoadLadderList = function()
    tes3mp.LogMessage(2, "Reading ladder_" .. os.date("%y%m") .. ".json")
    ladderList = jsonInterface.load("ladder_" .. os.date("%y%m") .. ".json")
end

-- Used to enable hardcore mode for new players
ccHardcore.HardcoreMode = function(pid)
    local newDifficulty = config.difficulty + ccHardcoreSettings.addedDifficulty
    local playerNameLC = string.lower(Players[pid].name)

    -- Enable hardcore mode
    Players[pid].data.hardcoreMode.enabled = 1
    Players[pid]:Save()

    -- Increase player's difficulty
    tes3mp.SetDifficulty(pid, newDifficulty)
    tes3mp.SendSettings(pid)

    tes3mp.SendMessage(pid, color.Orange .. Players[pid].name .. " has enabled " .. color.Red .. "Hardcore Mode." ..
        color.Orange .. " Good luck!\n", true)

    -- Avoid edge case where player creates character on last day then new month starts before server restart
    if ccHardcoreSettings.ladderEnabled == true and ccHardcore.LadderExists() == true then
        local hcLadder = "ladder_" .. os.date("%y%m")

        -- Ensure there's no residual pre-death info saved from another player
        if ladderList.players[playerNameLC] then
            ladderList.players[playerNameLC] = nil
            jsonInterface.save(hcLadder .. ".json", ladderList)
        end

        -- Create a table entry for this player in the ladder file
        local player = {} 
        player.displayName = Players[pid].data.login.name
        player.level = 1
        ladderList.players[playerNameLC] = player
        jsonInterface.save("ladder_" .. ccSettings.currentLadder .. ".json", ladderList)
    else
        tes3mp.SendMessage(pid, color.Red .. "ERROR: Failed to join the ladder. Please delete your character" ..
            " and try again after the next server restart.\n", false)
    end
end

-- Ensures the correct ladder file is present, mostly intended for end-of-month edge case
ccHardcore.LadderExists = function() 
    local hcLadder = os.date("%y%m")
    local ladderFile = io.open(ccConfig.dataPath .. "ladder_" .. hcLadder .. ".json", "r")

    if ladderFile then return true
    else return false
    end
end

-- Used to automatically generate monthly Hardcore ladders
-- https://stackoverflow.com/questions/16367524/copy-csv-file-to-new-file-in-lua
ccHardcore.LadderHandler = function()
    ccSettings.currentLadder = os.date("%y%m")
    local ladderFile = io.open(ccConfig.dataPath .. "ladder_" .. ccSettings.currentLadder .. ".json", "r")

    -- Ladder file is present so do nothing
    if ccHardcore.LadderExists() == true then
        tes3mp.LogMessage(1, "File for ladder " .. ccSettings.currentLadder .. " is present")
        return
    -- Ladder file is not present, so copy template file and write to new file using current month as title
    else
        tes3mp.LogMessage(1, "++++ File for ladder " .. ccSettings.currentLadder .. " is not present. Copying" ..
            " template file. ++++")

        local templateFile = io.open(ccConfig.dataPath .. "ladderTemplate.json", "r")
        local copyTemplate = templateFile:read("*a")
        templateFile:close()

        tes3mp.LogMessage(1, "++++ Template file copied. Writing JSON table. ++++")

        ladderFile = io.open(ccConfig.dataPath .. "ladder_" .. ccSettings.currentLadder .. ".json", "w")
        ladderFile:write(copyTemplate)
        ladderFile:close()
        tes3mp.LogMessage(1, "++++ File for ladder " .. ccSettings.currentLadder .. " created. ++++")
    end
end

-- Called from /ladder command, ranks players in current ladder file
ccHardcore.LadderParse = function(pid)

    -- Account for end-of-month edge case
    if not ccHardcore.LadderExists() then
        tes3mp.SendMessage(2, color.Red .. "Please wait until the next server restart for the new ladder." ..
            color.Default .. "\n", false)
        return false
    end

    local ladderChars = ladderList.players
    local ladderLabel = "Hardcore Ladder Rankings (" .. os.date("%y") .. "-" .. os.date("%m") .. ")"
    local ladderRanks = ""
    local ladderRaw = {}

    -- Populate temporary table "ladderRaw" with all players in current ladder
    for pid, p in pairs(ladderChars) do 
        local name = p.displayName
        local level = p.level
        ladderRaw[name] = level
    end

    -- Sort ladderRaw by highest-to-lowest
    for k,v in spairs(ladderRaw, function(t,a,b) return t[b] < t[a] end) do
        ladderRanks = ladderRanks .. k .. " (Level " .. v .. ")" .. "\n" 
    end

    -- Display the sorted players in a scrolllable box
    tes3mp.ListBox(pid, ccSettings.windowLadder, ladderLabel, ladderRanks)
end

ccHardcore.ProcessDeath = function(pid)
    deathLog(pid)

    local playerName = Players[pid].name
    local playerNameLC = string.lower(Players[pid].name)
    local timePlayed = Players[pid].data.timeKeeping.timePlayed

    local diffDays, diffHours, diffMinutes = ccScript.ParseTime(timePlayed, nil, 2)

    tes3mp.SendMessage(pid, color.Red .. "RIP: " .. playerName .. " died after surviving for " .. diffDays ..
        " day(s), " .. diffHours .. " hour(s), " .. diffMinutes .. " minute(s).\n", true)

    if ccDeathDrop.enabled == true then
        deathDrop(pid)
    end

    if ccHardcoreSettings.ladderEnabled == true and ccHardcore.LadderExists() == true then
        local hcLadder = "ladder_" .. os.date("%y%m")

        if ladderList.players[playerNameLC] then
            tes3mp.LogMessage(2, "++++ Removing player " .. playerName .. " from the ladder file ++++")
            ladderList.players[playerNameLC] = nil
            jsonInterface.save( hcLadder .. ".json", ladderList)
        end
    end

	if ccConfig.perksEnabled == true then

        if tokenList.players[playerName] then
            tes3mp.LogMessage(2, "++++ Removing player " .. playerName .. " from the token file ++++")
            tokenList.players[playerName] = nil
            jsonInterface.save( "tokenlist.json", tokenList)
        end
	end

    -- Thanks to mupf for this approach
    os.remove(ccConfig.playerPath .. Players[pid].data.login.name .. ".json")
    Players[pid]:Kick()
end

ccHardcore.SetupDeathDrop = function()
    tes3mp.LogMessage(2, "Populating death drop table with vanilla entries")

    for index, entryData in ipairs(ccDeathDrop.Vanilla.otherDrops) do
        table.insert(deathDropTable, entryData)
    end

    if string.lower(ccConfig.serverPlugins) == "tamriel" then -- TCC Tamriel
        tes3mp.LogMessage(2, "Populating death drop table with Tamriel entries")

        for index, entryData in ipairs(ccDeathDrop.Tamriel.otherDrops) do
            table.insert(deathDropTable, entryData)
        end
    end
end

--------------------
-- FUNCTIONS SECTION
--------------------

-- Drops a dead Hardcore player's gold on the ground
function deathDrop(pid)
    tes3mp.LogMessage(2, "++++ Running ccHardcore's deathDrop function ++++")

    -- First drop mandatory "otherDrops" from ccHardcoreConfig (if any)
    if #deathDropTable > 0 then
        tes3mp.LogMessage(2, "++++ deathDrop: deathDropTable has entries ++++")

        for index, value in pairs(deathDropTable) do
            dropItem(pid, deathDropTable[index][1], deathDropTable[index][2])
        end
    end

    -- Then look for any gold in player's inventory
    tes3mp.LogMessage(2, "++++ deathDrop: Looking for gold in player inventory ++++")

    for index, value in pairs(Players[pid].data.inventory) do

        if string.lower(Players[pid].data.inventory[index].refId) == "gold_001" then
            tes3mp.LogMessage(2, "++++ deathDrop: Dropping gold ++++")
            dropItem(pid, "gold_001", Players[pid].data.inventory[index].count)
            break
        end
    end
end

-- Logs death reason for HC characters
-- Modified from player/base.lua's ProcessDeath function
function deathLog(pid)
    local deathReason = "committed suicide"

    if tes3mp.DoesPlayerHavePlayerKiller(pid) then
        local killerPid = tes3mp.GetPlayerKillerPid(pid)

        if pid ~= killerPid then
            deathReason = "was killed by player " .. logicHandler.GetChatName(killerPid)
            tes3mp.LogAppend(1, "++++ " .. logicHandler.GetChatName(killerPid) .. " PKed HC player " ..
                logicHandler.GetChatName(pid) .. " in cell " .. tes3mp.GetCell(pid) .. " ++++")
        end
    else
        local killerName = tes3mp.GetPlayerKillerName(pid)

        if killerName ~= "" then
            deathReason = "was killed by " .. killerName
        end
    end

    local message = logicHandler.GetChatName(pid) .. " " .. deathReason .. ".\n"
    tes3mp.SendMessage(pid, message, true)
end

-- Drops an item on the ground and sends a packet to everyone else
function dropItem(pid, refId, count)
    local mpNum = WorldInstance:GetCurrentMpNum() + 1
    local cell = tes3mp.GetCell(pid)
    local location = {
        posX = tes3mp.GetPosX(pid), 
        posY = tes3mp.GetPosY(pid), 
        posZ = tes3mp.GetPosZ(pid)
    }
    local refIndex =  0 .. "-" .. mpNum

    WorldInstance:SetCurrentMpNum(mpNum)
    tes3mp.SetCurrentMpNum(mpNum)

    LoadedCells[cell]:InitializeObjectData(refIndex, refId)
    LoadedCells[cell].data.objectData[refIndex].location = location
    table.insert(LoadedCells[cell].data.packets.place, refIndex)
    LoadedCells[cell]:Save()

    for onlinePid, player in pairs(Players) do

        if player:IsLoggedIn() then
            tes3mp.InitializeEvent(onlinePid)
            tes3mp.SetEventCell(cell)
            tes3mp.SetObjectRefId(refId)
            tes3mp.SetObjectCount(count)
            tes3mp.SetObjectRefNumIndex(0)
            tes3mp.SetObjectMpNum(mpNum)

            tes3mp.SetObjectPosition(location.posX, location.posY, location.posZ)
            tes3mp.AddWorldObject()
            tes3mp.SendObjectPlace()
        end
    end
end

-- Sorts a given table by highest-to-lowest values
-- https://stackoverflow.com/questions/15706270/sort-a-table-in-lua
function spairs(t, order) 
    local keys = {}

    for k in pairs(t) do keys[#keys+1] = k end

    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    local i = 0
    return function()
        i = i + 1

        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

return ccHardcore
