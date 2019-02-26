---------------------------
-- ccDynamicDifficulty 0.7.0 by Texafornian
--
-- Requires "ccDynamicDifficultyConfig.lua" in /scripts/ folder!
-- Requires "ccHardcoreSettings.lua" in /scripts/ folder!

------------------
-- DO NOT TOUCH!
------------------

require("config")
require("ccsuite/ccDynamicDifficultyConfig")
require("ccsuite/ccHardcoreConfig")

------------------
-- METHODS SECTION
------------------

local ccDynamicDifficulty = {}

ccDynamicDifficulty.Main = function(event)
    local newDifficulty = tonumber(config.difficulty)
    local playerCount = tonumber(logicHandler.GetConnectedPlayerCount())

    newDifficulty = newDifficulty + (playerCount * ccDynamicDifficultySettings.difficultyPerPlayer)

    if ccDynamicDifficultySettings.maxDifficultyEnabled and newDifficulty > ccDynamicDifficultySettings.maxDifficulty then 
        newDifficulty = ccDynamicDifficultySettings.maxDifficulty 
    end

    for _, p in pairs(Players) do
        local tempDifficulty = newDifficulty

        if not p.data.hardcoreMode then
        elseif p.data.hardcoreMode.enabled then
            tempDifficulty = tempDifficulty + ccHardcoreSettings.addedDifficulty
        end

        -- Might not take effect until player changes cells
        p:SetDifficulty(tempDifficulty)
        p:LoadSettings()

        local message = "The difficulty has been "

        if event == "connect" then tes3mp.SendMessage(p.pid, color.Orange .. message .. "increased.\n", false)
        elseif event == "disconnect" then tes3mp.SendMessage(p.pid, color.Orange .. message .. "decreased.\n", false)
        end
    end
end

return ccDynamicDifficulty
