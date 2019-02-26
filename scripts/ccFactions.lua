---------------------------
-- ccFactions by Texafornian
--
-- Requires "ccConfig.lua" in /scripts/ccsuite/ folder!
-- Requires "factionlist.json" in /data/ folder!

------------------
-- DO NOT TOUCH!
------------------

tableHelper = require("tableHelper")
require("ccsuite/ccConfig")
require("ccsuite/ccFactionsConfig")
require("config")

factionList = {}

local ccSettings = {}

ccSettings.windowFaction = 81200
ccSettings.windowFactionCreate = 81201
ccSettings.windowFactionDelete = 81202
ccSettings.windowFactionInvite = 81203
ccSettings.windowFactionInviteInfo = 81204
ccSettings.windowFactionLeave = 81205
ccSettings.windowFactionList = 81206
ccSettings.windowFactionKickInfo = 81207
ccSettings.windowFactionMembers = 81208
ccSettings.windowFactionPromoteInfo = 81209
ccSettings.windowFactionStats = 81210

------------------
-- METHODS SECTION
------------------

local ccFactions = {}

-- Check whether player's stored faction still exists upon logging in and updates latest login time for faction
ccFactions.CheckPlayerMembership = function(pid)
    checkPlayerFileEntry(pid)
    tes3mp.LogMessage(1, "++++ ccFactions.CheckPlayerMembership: " .. Players[pid].name .. " called ++++")

    if isInAFaction(pid) then
        tes3mp.LogMessage(1, "++++ ccFactions.CheckPlayerMembership: " .. Players[pid].name .. " is/was in a faction ++++")
        local factionName = Players[pid].data.factions.id
        local factionNameLC = string.lower(factionName)

        if not doesFactionExist(factionNameLC) then
            tes3mp.LogMessage(1, "++++ ccFactions.CheckPlayerMembership: Removing " .. Players[pid].name .. " from faction due" ..
                " to deletion ++++")
            removePlayerFactionEntry(pid)
        else
            local playerName = Players[pid].name

            if tableHelper.containsValue(factionList.factions[factionNameLC].members, string.lower(playerName), false) then
                tes3mp.LogMessage(1, "++++ ccFactions.CheckPlayerMembership: " .. Players[pid].name .. " updated last login of" .. 
                    " faction " .. factionName .. " ++++")
                factionList.factions[factionNameLC].lastLogin = os.time()
                saveFactionList()
            else
                tes3mp.LogMessage(1, "++++ ccFactions.CheckPlayerMembership: Removing " .. Players[pid].name .. " from faction" ..
                    " due to being kicked ++++")
                removePlayerFactionEntry(pid)
            end
        end
    end
end

-- Sends faction chat message to online faction members
ccFactions.FactionChat = function(pid, chatMsg)
    local factionName = ""

    if not isInAFaction(pid) then
        local message = color.Red .. "You must be in a faction to use faction chat.\n"
        tes3mp.SendMessage(pid, message, false)
        return false
    else
        factionName = Players[pid].data.factions.id
        chatMsg = ccFactionsSettings.factionChatColor .. logicHandler.GetChatName(pid) .. ": " .. chatMsg
    end

    for _, p in pairs(Players) do -- Check connected players for faction's entry and send message

        if p ~= nil and p:IsLoggedIn() and p.data.factions.id == factionName then
            tes3mp.SendMessage(p.pid, chatMsg, false)
        end
    end
end

-- Called during server init, cleans up inactive factions
ccFactions.FactionClean = function()
    tes3mp.LogMessage(1, "Cleaning factionlist.json...")
    local factionNames = factionList.factions

    for i, f in pairs(factionNames) do

        if f.lastLogin == "" or type(f.lastLogin) == "string" then -- Shouldn't happen
            -- factionList.factions[i] = os.time()
            f.lastLogin = os.time()
        else
            local diff = (os.time() - f.lastLogin)

            if (diff / 86400) > ccConfig.daysInactive then
                factionList.factions[i] = nil
                tes3mp.LogMessage(1,"...deleting an inactive faction entry...")
            end
        end
    end

    jsonInterface.save("factionlist.json", factionList)
    tes3mp.LogMessage(1, "...factionlist.json has been cleaned")
end

-- Called from /faction; main ccFactions GUI window
ccFactions.FactionWindow = function(pid)
    local factionName = "None"
    local factionText = ""

    checkPlayerFileEntry(pid)
    tes3mp.LogMessage(1, "++++ ccFactions.FactionWindow: " .. Players[pid].name .. " called ++++")

    if not isInAFaction(pid) then
        factionText = "Create new faction\nList all factions\nCancel"
    else
        factionName = Players[pid].data.factions.id

        if tonumber(Players[pid].data.factions.rank) == 2 then
            factionText = "List all members\nInvite player to faction\nPromote member\nKick member\nDisband faction\n" ..
                "List all factions\nCancel"
        elseif tonumber(Players[pid].data.factions.rank) == 1 then
            factionText = "List all members\nInvite player to faction\nKick member\nLeave faction\nList all factions\nCancel"
        else
            factionText = "List all members\nLeave faction\nList all factions\nCancel"
        end
    end

    local factionLabel = "Current Faction: " .. factionName
    tes3mp.ListBox(pid, ccSettings.windowFaction, factionLabel, factionText)
end

-- Handles initial invitation of player to faction
ccFactions.InviteToFaction = function(pid, pid2)
    local factionName = ""
    local message = ""

    tes3mp.LogMessage(1, "++++ ccFactions.InviteToFaction: " .. Players[pid].name .. " called ++++")

    if isInAFaction(pid) and tonumber(Players[pid].data.factions.rank) >= 1 and pid ~= pid2 then
        factionName = Players[pid].data.factions.id
        tes3mp.LogMessage(1, "++++ ccFactions.InviteToFaction: Faction is " .. factionName .. " ++++")
    else
        message = color.Red .. "You must be the leader of a faction before you can invite someone. You can't invite yourself.\n"
        tes3mp.SendMessage(pid, message, false)
        return false
    end

    if Players[pid2] ~= nil and Players[pid2]:IsLoggedIn() then
        tes3mp.LogMessage(1, "++++ ccFactions.InviteToFaction: Target is " .. Players[pid2].name .. " ++++")

        if not isInAFaction(pid2) then
            windowFactionInvite(pid, pid2)
        else
            message = color.Red .. "That player is already in a faction.\n"
            tes3mp.SendMessage(pid, message, false)
        end
    else
        message = color.Red .. "That player pid is invalid or doesn't exist.\n"
        tes3mp.SendMessage(pid, message, false)
    end
end

-- Check chosen faction name versus existing factions and disallowed names
ccFactions.IsFactionNameOK = function(nameStr)
    local chosenName = string.lower(nameStr)
    local message = ""

    tes3mp.LogMessage(1, "++++ ccFactions.IsFactionNameOK: Checking string " .. nameStr .. " ++++")

    -- Check chosen name against existing factions
    if doesFactionExist(chosenName) then
        message = color.Red .. "A faction with that name already exists. Please choose a different name.\n"
        tes3mp.SendMessage(pid, message, false)
        return false
    end

    -- Check chosen names against disallowed names
    for _, disallowedName in pairs(config.disallowedNameStrings) do

        if string.find(chosenName, string.lower(disallowedName)) ~= nil then
            tes3mp.LogMessage(1, "++++ ccFactions.IsFactionNameOK: String check failed for " .. nameStr .. " ++++")
            message = color.Red .. "The chosen name contains a disallowed word. Please choose a different name.\n"
            tes3mp.SendMessage(pid, message, false)
            return false
        end
    end

    return true
end

-- Kicks a player from the faction
ccFactions.KickMember = function(pid, option, target)
    local message = ""

    checkPlayerFileEntry(pid)
    tes3mp.LogMessage(1, "++++ ccFactions.KickMember: " .. Players[pid].name .. " called  with " .. option .. ", " .. target ..
        " ++++")

    if isInAFaction(pid) and tonumber(Players[pid].data.factions.rank) >= 1 then
    else
        message = color.Red .. "You must hold the appropriate rank in a faction to use that command.\n"
        tes3mp.SendMessage(pid, message, false)
        return false
    end

    local factionNameLC = string.lower(Players[pid].data.factions.id)

    if option == "pid" then
        local targetPid = tonumber(target)

        if Players[targetPid] ~= nil and Players[targetPid]:IsLoggedIn() and pid ~= targetPid then
            checkPlayerFileEntry(targetPid)

            if isInAFaction(targetPid) and factionNameLC == string.lower(Players[targetPid].data.factions.id)
                and Players[targetPid].data.factions.rank == 2 then
                removePlayerFactionEntry(targetPid)
            else
                message = color.Red .. "You must be in the same faction as the person you want to kick. You can't kick the" ..
                    " faction creator.\n"
                tes3mp.SendMessage(pid, message, false)
                return false
            end
        else
            message = color.Red .. "That PID is invalid. Make sure you aren't trying to kick yourself.\n"
            tes3mp.SendMessage(pid, message, false)
            return false
        end
    elseif option == "name" then
        local targetString = ""

        tes3mp.LogMessage(1, "++++ ccFactions.KickMember: Beginning 'name' check ++++")

        if type(target) == "string" then
            targetString = target
        else

            if tostring(target) ~= nil then
                tes3mp.LogMessage(1, "++++ ccFactions.KickMember: 'name' -> tostring(target) ~= nil check ++++")
                targetString = tostring(target)
            else
                tes3mp.LogMessage(1, "++++ ccFactions.KickMember: Failed 'name' -> tostring(target) check with target " ..
                    target .. " ++++")
                message = color.Red .. "Player name input not recognized as a valid string.\n"
                tes3mp.SendMessage(pid, message, false)
                return false
            end
        end

        if string.lower(targetString) == string.lower(Players[pid].name) then
            message = color.Red .. "That name is invalid. Make sure you aren't trying to kick yourself.\n"
            tes3mp.SendMessage(pid, message, false)
            return false
        end

        local isOnline = false

        for _, player in pairs(Players) do
            tes3mp.LogMessage(1, "++++ ccFactions.KickMember: Failed 'name' -> tostring(target) check with target " ..
                target .. " ++++")

            if string.lower(targetString) == string.lower(player.name) then
                local currentPid = tonumber(player.pid)

                if pid ~= currentPid and factionNameLC == string.lower(Players[currentPid].data.factions.id) then

                    if Players[currentPid] ~= nil and Players[currentPid]:IsLoggedIn() then
                        tes3mp.LogMessage(1, "++++ ccFactions.KickMember: isOnline is true ++++")
                        isOnline = true
                        removePlayerFactionEntry(currentPid)
                    end
                else
                    message = color.Red .. "You must be in the same faction as the person you want to kick. You can't" ..
                        " kick yourself.\n"
                    tes3mp.SendMessage(pid, message, false)
                    return false
                end
            end
        end

        if not isOnline then
            tes3mp.LogMessage(1, "++++ ccFactions.KickMember: isOnline is false ++++")

            if removeFactionMemberEntry(factionNameLC, string.lower(targetString)) then
                tes3mp.LogMessage(1, "++++ ccFactions.KickMember: kicking " .. targetString .. " from faction ++++")
                message = color.Orange .. "You've kicked " .. targetString .. " from your faction.\n"
            else
                message = color.Red .. "That player is not a member of your faction.\n"
            end

            tes3mp.SendMessage(pid, message, false)
        end
    else
        message = color.Red .. "Kick command not recognized.\n"
        tes3mp.SendMessage(pid, message, false)
        return false
    end
end

-- Initializes token table
ccFactions.LoadFactionList = function()
	tes3mp.LogMessage(1, "Reading factionlist.json")
	factionList = jsonInterface.load("factionlist.json")
end

-- Displays correct window after player picks an option
ccFactions.OnGUIAction = function(pid, idGui, data)
    local pick = tonumber(data) -- Necessary when data = 0

    if idGui == ccSettings.windowFaction then

        if not isInAFaction(pid) then

            if pick == 0 then windowFactionCreate(pid)
            elseif pick == 1 then windowFactionList(pid)
            end
        else

            if tonumber(Players[pid].data.factions.rank) == 2 then

                if pick == 0 then windowFactionMembers(pid)
                elseif pick == 1 then windowFactionInviteInfo(pid)
                elseif pick == 2 then windowFactionPromoteInfo(pid)
                elseif pick == 3 then windowFactionKickInfo(pid)
                elseif pick == 4 then windowfactionDelete(pid)
                elseif pick == 5 then windowFactionList(pid)
                end
            elseif tonumber(Players[pid].data.factions.rank) == 1 then

                if pick == 0 then windowFactionMembers(pid)
                elseif pick == 1 then windowFactionInviteInfo(pid)
                elseif pick == 2 then windowFactionKickInfo(pid)
                elseif pick == 3 then windowFactionLeave(pid)
                elseif pick == 4 then windowFactionList(pid)
                end         
            else

                if pick == 0 then windowFactionMembers(pid)
                elseif pick == 1 then windowFactionLeave(pid)
                elseif pick == 2 then windowFactionList(pid)
                end
            end
        end
        return true
    elseif idGui == ccSettings.windowFactionCreate then
        factionCreate(pid, data)
        return true
    elseif idGui == ccSettings.windowFactionDelete then

        if pick == 0 then factionDelete(pid) end
        return true
    elseif idGui == ccSettings.windowFactionLeave then

        if pick == 0 then factionLeave(pid) end
        return true
    -- elseif idGui == ccSettings.windowFactionStats then

        -- if pick == 0 then factionStats() end
        -- return true
    elseif idGui >= ccSettings.windowFactionInvite and idGui <= (ccSettings.windowFactionInvite + ccConfig.numberOfPlayers) then

        if pick == 0 then
            local calculatedPid = idGui - ccSettings.windowFactionInvite
            local factionName = Players[calculatedPid].data.factions.id

            factionJoin(pid, factionName)
        end
        return true
    end
    return false
end

-- Promote a player of rank 0 (member) to rank 1 (officer)
ccFactions.PromoteMember = function(pid, targetPid)
    local factionName = ""
    local message = ""

    tes3mp.LogMessage(1, "++++ ccFactions.PromoteMember: " .. Players[pid].name .. " called ++++")

    if isInAFaction(pid) and tonumber(Players[pid].data.factions.rank) == 2 and pid ~= targetPid then
        factionName = Players[pid].data.factions.id
        tes3mp.LogMessage(1, "++++ ccFactions.PromoteMember: Faction is " .. factionName .. " ++++")
    else
        message = color.Red .. "You must be the leader of a faction before you can promote someone. You can't promote yourself.\n"
        tes3mp.SendMessage(pid, message, false)
        return false
    end

    if Players[targetPid] ~= nil and Players[targetPid]:IsLoggedIn() then
        tes3mp.LogMessage(1, "++++ ccFactions.PromoteMember: Target is " .. Players[targetPid].name .. " ++++")

        if not isInAFaction(targetPid) or Players[targetPid].data.factions.id ~= factionName then
            message = color.Red .. "That player is not a member of your faction.\n"
            tes3mp.SendMessage(pid, message, false)
            return false
        end
    else
        message = color.Red .. "That player pid is invalid or doesn't exist.\n"
        tes3mp.SendMessage(pid, message, false)
        return false
    end

    if Players[targetPid].data.factions.rank == 0 then
        tes3mp.LogMessage(1, "++++ ccFactions.PromoteMember: Promoting " .. Players[targetPid].name .. " to officer ++++")
        Players[targetPid].data.factions.rank = 1
        Players[targetPid]:Save()
        message = color.Orange .. "You have promoted a faction member.\n"
    else
        message = color.Red .. "You can't promote that faction member.\n"
    end

    tes3mp.SendMessage(pid, message, false)
end

-- Called from admin-only command: /faction delete <faction name>
ccFactions.RemoveFactionFromList = function(pid, factionName)
    local factionNameLC = string.lower(factionName)
    local message = ""

    if doesFactionExist(factionNameLC) then

        if factionList.factions[factionNameLC] then
            factionList.factions[factionNameLC] = nil
            saveFactionList()
        end

        for _, p in pairs(Players) do -- Check connected players for this faction's entry and remove it

            if p ~= nil and p:IsLoggedIn() then
            
                if string.lower(p.data.factions.id) == factionNameLC then 
                    removePlayerFactionEntry(p.pid)
                end
            end
        end

        message = color.Orange .. "A faction has been disbanded: " .. factionName .. ".\n"
        tes3mp.SendMessage(pid, message, true)
    else
        message = color.Red .. "That faction doesn't exist. Type the name exactly as it appears in the list without quotation marks.\n"
        tes3mp.SendMessage(pid, message, false)
    end
end

--------------------
-- FUNCTIONS SECTION
--------------------

-- Check whether player file has the "factions" data table
function checkPlayerFileEntry(pid)

    if Players[pid].data.factions then
    else
        local newInfo = {}

        newInfo.id = ""
        newInfo.rank = 0
        Players[pid].data.factions = newInfo
        Players[pid]:Save()
    end
end

-- Checks whether the chosen faction exists in factionlist.json
function doesFactionExist(factionName)

    if factionList.factions[factionName] then return true
    else return false
    end
end

-- Add news faction to factionlist.json, calls factionJoin to update player data
function factionCreate(pid, factionName)
    local playerName = Players[pid].name

    if not isFactionNameOK(pid, factionName) then return false end

    local factionNameLC = string.lower(factionName)
    local factionInfo = {}

    factionInfo.displayName = factionName
    factionInfo.creationTime = os.time()
    factionInfo.lastLogin = os.time()
    factionInfo.leader = string.lower(playerName)
    factionInfo.members = {}
    factionList.factions[factionNameLC] = factionInfo
    saveFactionList()

    factionJoin(pid, factionName)
end

-- Delete the faction from factionlist.json and remove entries from connected members
function factionDelete(pid)
    tes3mp.LogMessage(1, "++++ ccFactions.factionDelete: " .. Players[pid].name .. " called ++++")
    local factionName = Players[pid].data.factions.id
    local factionNameLC = string.lower(factionName)
    local playerName = Players[pid].name

    if factionList.factions[factionNameLC] then -- Remove faction entry from factionlist.json
        tes3mp.LogMessage(1, "++++ ccFactions.factionDelete: Deleting faction " .. factionName .. "... ++++")
        factionList.factions[factionNameLC] = nil
        saveFactionList()
        tes3mp.LogMessage(1, "++++ ccFactions.factionDelete: ...faction " .. factionName .. " was deleted ++++")
    end

    for _, p in pairs(Players) do -- Check connected players for this faction's entry and remove it
        tes3mp.LogMessage(1, "++++ ccFactions.factionDelete: Iterating through 'for' loop ++++")

        if p ~= nil and p:IsLoggedIn() then

            if string.lower(p.data.factions.id) == factionNameLC then
                tes3mp.LogMessage(1, "++++ ccFactions.factionDelete: Clearing faction entry from player file of " .. p.name .. " ++++")
                removePlayerFactionEntry(p.pid)
            end
        end
    end

    tes3mp.LogMessage(1, "++++ ccFactions.factionDelete: Reached end ++++")

    local message = color.Green .. playerName .. " has disbanded a faction:\n" .. color.Yellow .. factionName .. color.Green .. ".\n"
    tes3mp.SendMessage(pid, message, true)
end

-- Finishes faction joining, updates player and factionlist.json files with new membership info
function factionJoin(pid, factionName)
    checkPlayerFileEntry(pid)

    local playerName = Players[pid].name
    local factionNameLC = string.lower(factionName)

    table.insert(factionList.factions[factionNameLC].members, string.lower(playerName))
    jsonInterface.save("factionlist.json", factionList)

    local message = color.Green .. playerName .. " has "

    if string.lower(playerName) == factionList.factions[factionNameLC].leader then
        message = message .. "formed a new faction: " .. color.Yellow .. factionName .. ".\n"
        Players[pid].data.factions.rank = 2
    else
        message = message .. "joined a faction: " .. color.Yellow .. factionName .. ".\n"
    end

    Players[pid].data.factions.id = factionName
    Players[pid]:Save()

    tes3mp.SendMessage(pid, message, true)
end

-- Removes player from faction if not leader, disbands faction if leader
function factionLeave(pid)
    local factionNameLC = string.lower(Players[pid].data.factions.id)
    local playerName = Players[pid].name

    if string.lower(playerName) == factionList.factions[factionNameLC].leader then
        factionDelete(pid)
    else
        removePlayerFactionEntry(pid)
        removeFactionMemberEntry(factionNameLC, playerName)
    end
end

-- Checks chosen faction name versus existing factions and disallowed names
function isFactionNameOK(pid, factionName)
    local chosenName = string.lower(factionName)
    local message = ""

    -- Check chosen name against existing factions
    if doesFactionExist(chosenName) then
        message = color.Red .. "A faction with that name already exists. Please choose a different name.\n"
        tes3mp.SendMessage(pid, message, false)
        return false
    end

    -- Check chosen names against disallowed names
    for _, disallowedName in pairs(config.disallowedNameStrings) do

        if string.find(chosenName, string.lower(disallowedName)) ~= nil then
            message = color.Red .. "The chosen name contains a disallowed word. Please choose a different name.\n"
            tes3mp.SendMessage(pid, message, false)
            return false
        end
    end

    return true
end

-- Checks whether a player is a member of any faction
function isInAFaction(pid)

    if Players[pid].data.factions.id == nil or Players[pid].data.factions.id == "" then
        return false
    else return true
    end
end

-- Removes a player from a faction
function removeFactionMemberEntry(factionNameLC, playerName)

    if tableHelper.containsValue(factionList.factions[factionNameLC].members, string.lower(playerName), false) then
        tableHelper.removeValue(factionList.factions[factionNameLC].members, string.lower(playerName))
        saveFactionList()
        return true
    else return false
    end
end

-- Remove faction entry from player files after faction is deleted
function removePlayerFactionEntry(pid)
    local factionName = Players[pid].data.factions.id
    local factionNameLC = string.lower(factionName)
    local playerName = Players[pid].name

    Players[pid].data.factions.id = ""
    Players[pid].data.factions.rank = 0
    Players[pid]:Save()

    local message = ""

    if not doesFactionExist(factionNameLC) then
        message = color.Orange .. "You have been removed from your faction because it no longer exists.\n"
        tes3mp.SendMessage(pid, message, false)
    else
        removeFactionMemberEntry(factionNameLC, playerName)
        message = color.Orange .. playerName .. " is no longer a member of:\n" .. color.Yellow .. factionName .. "\n"
        tes3mp.SendMessage(pid, message, true)
    end
end

-- Saves factionlist.json
function saveFactionList()
    tes3mp.LogMessage(1, "++++ Saving factionlist.json ++++")
    jsonInterface.save("factionlist.json", factionList)
end

-- Asks the player to input a name for their new faction 
function windowFactionCreate(pid)
    local createLabel = "Please enter a name for your faction."
    tes3mp.InputDialog(pid, ccSettings.windowFactionCreate, createLabel, "")
end

-- Asks the player to confirm Yes/No whether they want to delete faction
function windowfactionDelete(pid)
    local deleteText = "Are you sure you want to disband your faction?"
    tes3mp.CustomMessageBox(pid, ccSettings.windowFactionDelete, deleteText, "Yes;No")
end

-- Controls inviting other online players into your faction
function windowFactionInvite(pid, targetPid)
    local factionName = Players[pid].data.factions.id
    local factionPlayer = Players[pid].name
    local message = color.Blue .. "Invitation sent. Waiting on response...\n"
    tes3mp.SendMessage(pid, message, false)

    local inviteIdGui = tonumber(pid + ccSettings.windowFactionInvite)
    local inviteText = factionPlayer .. " has invited you to join their faction:\n" .. factionName .. ".\n\nClick 'Yes'" ..
        " to accept the invitation, or 'No' to reject it."

    tes3mp.CustomMessageBox(targetPid, inviteIdGui, inviteText, "Yes;No")
end

-- Gives the player info on how to invite others to their faction
function windowFactionInviteInfo(pid)
    local inviteInfoText = "Type the following command to invite a player to your faction:\n\n/faction invite <pid>\n\nUse" ..
        " /list to determine their pid."
    tes3mp.CustomMessageBox(pid, ccSettings.windowFactionInviteInfo, inviteInfoText, "Ok")
end

-- Asks the player to confirm Yes/No whether they want to leave their faction
function windowFactionLeave(pid)
    local leaveText = "Are you sure that you want to leave your faction?"
    tes3mp.CustomMessageBox(pid, ccSettings.windowFactionLeave, leaveText, "Yes;No")
end

-- Creates window that displays all factions
function windowFactionList(pid)
    local listLabel = "Faction (Leader)"
    local listText = ""

    for _, faction in pairs(factionList.factions) do
        local leaderName = faction.leader
        listText = listText .. faction.displayName .. " (" .. leaderName .. ")\n"
    end

    tes3mp.ListBox(pid, ccSettings.windowFactionList, listLabel, listText)
end

-- Gives the player info on how to kick members of their faction
function windowFactionKickInfo(pid)
    local kickInfoText = "Type the following command to kick a member from your faction:\n\n/faction kick name/pid <name/pid>" ..
        "\n\nUse /list to determine the pid of a connected player."
    tes3mp.CustomMessageBox(pid, ccSettings.windowFactionKickInfo, kickInfoText, "Ok")
end

-- Creates window that displays all members in player's functions
function windowFactionMembers(pid)
    local factionName = string.lower(Players[pid].data.factions.id)
    local memberLabel = "List of faction members"
    local memberText = ""

    for _, member in pairs(factionList.factions[factionName].members) do
        memberText = memberText .. member .. "\n"
    end

    tes3mp.ListBox(pid, ccSettings.windowFactionMembers, memberLabel, memberText)
end

-- Gives the player info on how to promote players within their faction
function windowFactionPromoteInfo(pid)
    local promoteInfoText = "Type the following command to promote a player in your faction:\n\n/faction promote <pid>\n\nUse" ..
        " /list to determine their pid."
    tes3mp.CustomMessageBox(pid, ccSettings.windowFactionPromoteInfo, promoteInfoText, "Ok")
end

-- Creates window that displays stats about the faction such as age and # of members
-- function windowFactionStats(pid)
    -- local statsLabel = "Faction Stats"
    -- local statsText = ""
    -- tes3mp.ListBox(pid, ccSettings.windowFactionStats, statsLabel, statsText)
-- end

return ccFactions
