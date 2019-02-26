---------------------------
-- ccAdvanceQuests 0.7.0 by Texafornian
--
-- Requires "ccConfig.lua" in /scripts/ folder!
--
-- More quests can be added to "questInfo"
-- Format: type, index, quest, actorRefId

-----------------
-- CONFIG SECTION
-----------------

tableHelper = require("tableHelper")
require("ccsuite/ccConfig")
require("ccsuite/ccAdvanceQuestsConfig")

------------------
-- METHODS SECTION
------------------

local ccAdvanceQuests = {}

-- If server isn't set to always wipe world file on restart (ccAdvanceQuestsConfig),
-- then compare the current hour (on startup) to the appropriate wipe time table
ccAdvanceQuests.CheckTime = function()
    tes3mp.LogMessage(2, "Checking time for ccAdvanceQuest")

    if not ccAdvanceQuestSettings.alwaysWipeOnRestart then
        local currentHour = os.date("%H")
        local wipeTimes = {}

        if string.lower(ccConfig.serverPlugins) == "tamriel" then -- TCC Tamriel
            wipeTimes = ccAdvanceQuestSettings.Tamriel.WipeTimes
        else
            wipeTimes = ccAdvanceQuestSettings.Vanilla.WipeTimes
        end

        for index, _ in pairs(wipeTimes) do

            if currentHour == wipeTimes[index][1] then
                advanceQuests()
                break
            end
        end
    else
        advanceQuests()
    end
end

--------------------
-- FUNCTIONS SECTION
--------------------

-- Clear the journal and topics list, add vanilla info (ccAdvanceQuestsConfig),
-- then add Tamriel info if applicable
function advanceQuests()
    tes3mp.LogMessage(2, "Resetting world data entries")

    WorldInstance.data.factionRanks = {}
    WorldInstance.data.factionExpulsion = {}
    WorldInstance.data.fame = {}
    WorldInstance.data.journal = {}
    WorldInstance.data.kills = {}

    for _, item in pairs(ccAdvanceQuestSettings.Vanilla.Quests) do
        local journalItem = {
            type = item[1],
            index = item[2],
            quest = item[3],
            actorRefId = item[4]
        }

        table.insert(WorldInstance.data.journal, journalItem)
    end

    for _, topicId in pairs(ccAdvanceQuestSettings.Vanilla.Topics) do

        if not tableHelper.containsValue(WorldInstance.data.topics, topicId[1]) then
            table.insert(WorldInstance.data.topics, topicId[1])
        end
    end

    if string.lower(ccConfig.serverPlugins) == "tamriel" then -- TCC Tamriel

        for _, item in pairs(ccAdvanceQuestSettings.Tamriel.Quests) do
            local journalItem = {
                type = item[1],
                index = item[2],
                quest = item[3],
                actorRefId = item[4]
            }

            table.insert(WorldInstance.data.journal, journalItem)
        end

        for _, topicId in pairs(ccAdvanceQuestSettings.Tamriel.Topics) do

            if not tableHelper.containsValue(WorldInstance.data.topics, topicId[1]) then
                table.insert(WorldInstance.data.topics, topicId[1])
            end
        end
    end

    WorldInstance:Save()
end

return ccAdvanceQuests
