# ccSuite
Custom script suite on the TES3MP 0.6.2-hotfixed server "The Cornerclub"

Everything has been dehardcoded into easily-configurable tables (...Config.lua files) with optional support for Tamriel_Data content

Any ccSuite module can be enabled or disabled by changing a single line in ccConfig.lua

# ccScript (Required)
* Spawn location/starting clothes/starting weapon randomizer
* Customizable MOTD that welcomes players after chargen
* /stats - Allows players to track their time on the server
* /deletecharacter
* Punish players by sending them to random configurable cells
* Three info windows - choose their /command and message

# ccAdvanceQuest
* Choose when your world file will be wiped, if at all
* Choose which dialogue topics will be added to the world file

# ccHardcore
* Players can opt into "permadeath" after chargen
* /ladder - Displays the HC players from highest level to lowest
* Configure whether HC players drop gold on death
* Configure optional safe cells (ccConfig.lua) for HC players

# ccPerks
* Token system - Players earn tokens every day and every second level-up
* Every perk, including its token cost, is customizable in ccPerksConfig.lua
* Lottery
* Appear as Creature
* Birthsign changer
* Head changer
* Hair changer
* Gender changer
* Race changer
* Spawn pet (buggy)
* Warp

# ccServerMsg
* Choose when and what messages will automatically appear every hour
* If relying on a restart schedule, warn players in advance with a warning

# Configuration
* Use ccConfig.lua to enable or disable various modules
* Everything can be customized in each module's Config file
* Make sure to follow the correct format for each entry
* Don't forget commas!

# Installation
Download the entire repo and drag the contents into their respective data and scripts folders in either .../mp-stuff/ (WINDOWS) or .../PluginExamples (LINUX PACKAGE), then read below.

# Changes to .../scripts/server.lua
Open the **server.lua** file and make the following changes (use CTRL-F or something similar):

```
menuHelper = require("menuHelper")
```
to:
```
menuHelper = require("menuHelper")

-- ~~~~~ BEGINNING OF CUSTOM ADDITIONS ~~~~~ --
require("ccServerMsg")
ccScript = require("ccScript")
-- ~~~~~ END OF CUSTOM ADDITIONS ~~~~~ --
```

```
tes3mp.SetPluginEnforcementState(config.enforcePlugins)
```
to:
```
tes3mp.SetPluginEnforcementState(config.enforcePlugins)

-- ~~~~~ BEGINNING OF CUSTOM ADDITIONS ~~~~~ --
ccScript.SetupSuite()
-- ~~~~~ END OF CUSTOM ADDITIONS ~~~~~ --
```

```
else
    local message = "Not a valid command. Type /help for more info.\n"
    tes3mp.SendMessage(pid, color.Error..message..color.Default, false)
end
```
to:
```
-- ~~~~~ BEGINNING OF CCSCRIPT ADDITIONS ~~~~~ --

elseif cmd[1] == "coords" and admin then
    ccScript.Coords(pid)

elseif cmd[1] == "deletecharacter" then
    ccScript.DeleteCharWindow(pid)

elseif cmd[1] == ccInfoWindow.Window1.command and ccInfoWindow.Window1.message ~= nil then
    tes3mp.CustomMessageBox(pid, -1, ccInfoWindow.Window1.message .. "\n", "Ok")

elseif cmd[1] == ccInfoWindow.Window2.command and ccInfoWindow.Window2.message ~= nil then
    tes3mp.CustomMessageBox(pid, -1, ccInfoWindow.Window2.message .. "\n", "Ok")

elseif cmd[1] == ccInfoWindow.Window3.command and ccInfoWindow.Window3.message ~= nil then
    tes3mp.CustomMessageBox(pid, -1, ccInfoWindow.Window3.message .. "\n", "Ok")

elseif cmd[1] == "punish" and cmd[2] ~= nil and tonumber(cmd[3]) ~= nil and moderator then

    if cmd[2] == "cell" then
        ccScript.PunishCell(pid, cmd[3])
    elseif cmd[2] == "ocean" then
        ccScript.PunishOcean(pid, cmd[3])
    end

elseif cmd[1] == "roll" then
    ccScript.Roll(pid)

elseif cmd[1] == "setbounty" and cmd[2] ~= nil and tonumber(cmd[2]) ~= nil and cmd[3] ~= nil and tonumber(cmd[3]) ~= nil and admin then
    ccScript.Bounty(pid, tonumber(cmd[2]), tonumber(cmd[3]))		

elseif cmd[1] == "smsg" and cmd[2] ~= nil and moderator then
    local message = color.Orange .. "SERVER: " .. tableHelper.concatenateFromIndex(cmd, 2) .. "\n"
    tes3mp.SendMessage(pid, message, true)

elseif cmd[1] == "stats" then
    
    if Players[pid].data.timeKeeping then
        ccScript.TimeOnServer(pid)
    else
        tes3mp.SendMessage(pid, color.Yellow .. "Your character was created before this feature was implemented.\n", true)
    end

elseif cmd[1] == "stuck" then
    ccScript.Stuck(pid)

-- ~~~~~ BEGINNING OF CCPERKS ADDITIONS ~~~~~ --

elseif cmd[1] == "addtoken" and cmd[2] == "all" and tonumber(cmd[3]) ~= nil and admin then
    ccPerks.TokenAddAll(pid, tonumber(cmd[3]))

elseif cmd[1] == "addtoken" and tonumber(cmd[2]) ~= nil and tonumber(cmd[3]) ~= nil and admin then
    ccPerks.TokenAdd(pid, tonumber(cmd[2]), tonumber(cmd[3]))

elseif cmd[1] == "checktoken" and cmd[2] ~= nil and admin then
    ccPerks.TokenCheck(pid, cmd[2])

elseif cmd[1] == "perks" then
    ccPerks.PerksWindow(pid)

elseif cmd[1] == "ladder" then
    ccHardcore.LadderParse(pid)

-- ~~~~~ BEGINNING OF CCHARDCORE ADDITIONS ~~~~~ --

elseif cmd[1] == "ladder" then
    ccHardcore.LadderParse(pid)

-- ~~~~~ END OF CUSTOM ADDITIONS ~~~~~ --

else
    local message = "Not a valid command. Type /help for more info.\n"
    tes3mp.SendMessage(pid, color.Error..message..color.Default, false)
end
```

```
function OnPlayerDeath(pid)
    myMod.OnPlayerDeath(pid)
end
```
to:
```
function OnPlayerDeath(pid)
    --myMod.OnPlayerDeath(pid)
    ccScript.OnPlayerDeath(pid)
end
```

```
function OnPlayerLevel(pid)
    myMod.OnPlayerLevel(pid)
end
```
to:
```
function OnPlayerLevel(pid)
    myMod.OnPlayerLevel(pid)
	ccScript.OnPlayerLevel(pid)
end
```

```
function OnPlayerCellChange(pid)
    myMod.OnPlayerCellChange(pid)
end
```
to:
```
function OnPlayerCellChange(pid)
    --myMod.OnPlayerCellChange
	ccScript.OnPlayerCellChange(pid)
end
```

```
function OnPlayerEndCharGen(pid)
    myMod.OnPlayerEndCharGen(pid)
end
```
to:
```
function OnPlayerEndCharGen(pid)
    --myMod.OnPlayerEndCharGen(pid)
    ccScript.OnPlayerEndCharGen(pid)
end
```

```
function OnGUIAction(pid, idGui, data)
    if myMod.OnGUIAction(pid, idGui, data) then return end
end
```
to:
```
function OnGUIAction(pid, idGui, data)
    if myMod.OnGUIAction(pid, idGui, data) then return
	elseif ccScript.OnGUIAction(pid, idGui, data) then return
	end
end
```

# Changes to .../scripts/player/base.lua
Open the **base.lua** file and make the following changes (use CTRL-F or something similar):

*function BasePlayer:EndCharGen()*:
```
    WorldInstance:LoadKills(self.pid)
end
```
to:
```
    WorldInstance:LoadKills(self.pid)
	
    if ccMOTD.enabled == true then
        ccScript.MOTD(self.pid)
    end
end
```
