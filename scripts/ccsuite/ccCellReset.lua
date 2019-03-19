---------------------------
-- ccCellReset 0.7.0 by Texafornian
--
-- Many thanks to Urm for json approach

-----------------
-- FUNCTIONS
-----------------

function ccCellReset.deleteCells()
    -- Performs deletion of non-preserved cells
    tes3mp.LogMessage(2, "[ccCellReset] Populating cell preservation table with vanilla entries")
    local preserveTable = {}

    for _, preserveData in ipairs(ccConfig.CellReset.SavedCells.Vanilla) do
        table.insert(preserveTable, preserveData)
    end

    if string.lower(ccConfig.ServerPlugins) == "tamriel" then -- TCC Tamriel
        tes3mp.LogMessage(2, "[ccCellReset] Populating cell preservation table with Tamriel entries")

        for _, preserveData in ipairs(ccConfig.CellReset.SavedCells.Tamriel) do
            table.insert(preserveTable, preserveData)
        end
    end

    if ccConfig.CellReset.SaveBuildCell then
        tes3mp.LogMessage(2, "[ccCellReset] Adding ccBuild cell to preservation table")
        table.insert(preserveTable, ccConfig.Build.BuildCell[1])
    end

    if ccConfig.CellReset.SaveFactionCells then

        for faction, _ in pairs(ccFactions.FactionList) do

            if ccFactions.FactionList[faction].cells[1] then
                tes3mp.LogMessage(2, "[ccCellReset] Adding " .. ccFactions.FactionList[faction].displayName
                .. " faction cell to preservation table")
                table.insert(preserveTable, ccFactions.FactionList[faction].cells[1]) 
            end
        end
    end

    -- Load the list of cells to be deleted
    tes3mp.LogMessage(2, "[ccCellReset] Loading cellresetlist.json")
    ccCellReset.CellResetList = jsonInterface.load("cellresetlist.json")

    -- Delete cells listed in cellresetlist.json
    tes3mp.LogMessage(2, "[ccCellReset] Deleting cells")

    for listEntry, _ in pairs(ccCellReset.CellResetList) do
        local deleteCell = true
        local cellName = ""

        for _, preserveCell in pairs(preserveTable) do

            if listEntry == preserveCell then
                deleteCell = false
                cellName = preserveCell
            end
            break
        end

        if deleteCell then os.remove(ccConfig.CellPath .. listEntry .. ".json")
        else tes3mp.LogMessage(2, "[ccCellReset] Ignoring cell " .. cellName)
        end
    end

    -- Clear the list of cells and save
    tes3mp.LogMessage(2, "[ccCellReset] Saving cellresetlist.json")
    ccCellReset.CellResetList = {}
    jsonInterface.save("cellresetlist.json", ccCellReset.CellResetList)
end

-----------------
-- EVENTS
-----------------

function ccCellReset.OnCellUnload(eventStatus, pid, cellDescription)
    -- Update cellresetlist.json when player leaves cell

    if ccCellReset.CellResetList[cellDescription] == nil then ccCellReset.CellResetList[cellDescription] = {} end
    jsonInterface.save("cellresetlist.json", ccCellReset.CellResetList)
end

function ccCellReset.OnServerPostInit(eventStatus)
    -- Checks time then populates cell preservation table
    tes3mp.LogMessage(2, "[ccCellReset] Checking time for cell reset")

    if not ccConfig.CellReset.AlwaysWipeOnRestart then
        local currentHour = os.date("%H")
        local wipeTimes = {}

        if string.lower(ccConfig.ServerPlugins) == "tamriel" then -- TCC Tamriel
            wipeTimes = ccConfig.CellReset.WipeTimes.Tamriel
        else
            wipeTimes = ccConfig.CellReset.WipeTimes.Vanilla
        end

        for index, _ in pairs(wipeTimes) do

            if currentHour == wipeTimes[index][1] then
                ccCellReset.deleteCells()
                break
            end
        end
    else ccCellReset.deleteCells()
    end
end

if ccConfig.CellResetEnabled then
    customEventHooks.registerValidator("OnCellUnload", ccCellReset.OnCellUnload)
    customEventHooks.registerHandler("OnServerPostInit", ccCellReset.OnServerPostInit)
end

return ccCellReset
