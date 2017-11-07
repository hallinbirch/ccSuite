# The Cornerclub 0.6.1 Scripts
Custom scripts on the TES3MP 0.6.1 server "The Cornerclub"

# Features
* Spawn location/clothes randomizer
* Token system
* Lottery
* Appear as creature
* Head changer
* Hair changer
* Gender changer
* Punish-player command

# Installation
Download data/tokenlist.json and scripts/ccScript.lua and put both in the respective data and scripts folders in either .../mp-stuff/ (WINDOWS) or .../PluginExamples (LINUX PACKAGE), then read below.

# Changes to .../scripts/server.lua
Open the **server.lua** file and make the following changes (use CTRL-F or something similar):

Find and replace:
```
myMod = require("myMod")

Database = nil
Player = nil
Cell = nil
World = nil
```
with:
```
myMod = require("myMod")
ccScript = require("ccScript")

Database = nil
Player = nil
Cell = nil
World = nil
```

Find and replace:
```
banList = {}
pluginList = {}
timeCounter = config.timeServerInitTime
```
with:
```
banList = {}
pluginList = {}
tokenList = {}
spawnTable = {}
timeCounter = config.timeServerInitTime
```

Find and replace the block starting with:
```
local helptext =
```
with:
```
local perkstext = "\nPerks list:\n\
/lottery - You might win a prize! [1 token]\n\
/setgender <0 or 1> - Permanently changes your gender. Log off & on to apply it. [1 token]\
/sethair <number> - Permanently changes your hair. Log off & on to apply it. [1 token]\
/sethead <number> - Permanently changes your head. Log off & on to apply it. [1 token]\n\
EXPERIMENTAL (Possibly buggy):\
/setcreature <ID> - You appear as the creature to other players until you log out [1 token]\
/setcreature list - See all possible IDs for /setcreature\n\
(More Coming Soon)"

local creaturetext = "\n/setcreature IDs:\n\
alit, ancestor_ghost, ascended_sleeper, ash_ghoul,\
ash_slave, ash_zombie, atronach_flame,\
atronach_frost, atronach_storm, bear_black,\
bear_brown, bear_snow, bonelord, clannfear,\
cliff_racer, corprus_lame, corprus_stalker,\
daedroth, draugr, dremora, durzog, dwemer_ghost,\
fabricant_hulking, fabricant_verminous,\
frost_giant, ice_troll, goblin, guar, guar_white,\
hunger, kagouti, kwama_forager, kwama_warrior,\
kwama_worker, horker, mudcrab, netch_betty,\
netch_bull, nix-hound, ogrim, riekling, scamp,\
scrib, shalk, skeleton, spriggan, vivec,\
winged_twilight, wolf_bone, wolf_gray, wolf_red,\
wolf_snow"

local helptext = "\nCommand list:\n\
/message <pid> <text> - Send a private message to a player (/pm or /msg)\
/me <text> - Send a message written in the third person\
/local <text> - Send a message that only players in your area can read (/l)\
/list - List all players on the server\
/claimtoken - Receive a token once a day\
/checktoken - Checks your total number of tokens\
/perks - Spend your tokens on special commands\
/roll - Rolls the dice"
```

Find and replace:
```
function LoadPluginList()
    tes3mp.LogMessage(2, "Reading pluginlist.json")

    local pluginList2 = jsonInterface.load("pluginlist.json")
    for idx, pl in pairs(pluginList2) do
        idx = tonumber(idx) + 1
        for n, h in pairs(pl) do
            pluginList[idx] = {n}
            io.write(("%d, {%s"):format(idx, n))
            for _, v in ipairs(h) do
                io.write((", %X"):format(tonumber(v, 16)))
                table.insert(pluginList[idx], tonumber(v, 16))
            end
            table.insert(pluginList[idx], "")
            io.write("}\n")
        end
    end
end
```
with:
```
function LoadPluginList()
    tes3mp.LogMessage(2, "Reading pluginlist.json")

    local pluginList2 = jsonInterface.load("pluginlist.json")
    for idx, pl in pairs(pluginList2) do
        idx = tonumber(idx) + 1
        for n, h in pairs(pl) do
            pluginList[idx] = {n}
            io.write(("%d, {%s"):format(idx, n))
            for _, v in ipairs(h) do
                io.write((", %X"):format(tonumber(v, 16)))
                table.insert(pluginList[idx], tonumber(v, 16))
            end
            table.insert(pluginList[idx], "")
            io.write("}\n")
        end
    end
end

function LoadTokenList()
	tes3mp.LogMessage(2, "Reading tokenlist.json")
	
	tokenList = jsonInterface.load("tokenlist.json")
	
	if tokenList == nil then
		tokenList.players = {}
	end
end
```

Find and replace:
```
function OnServerInit()

    local version = tes3mp.GetServerVersion():split(".") -- for future versions

    if tes3mp.GetServerVersion() ~= "0.6.1" then
        tes3mp.LogMessage(3, "The server or script is outdated!")
        tes3mp.StopServer(1)
    end

    myMod.InitializeWorld()
    myMod.PushPlayerList(Players)

    LoadBanList()
    LoadPluginList()
end
```
with:
```
function OnServerInit()

    local version = tes3mp.GetServerVersion():split(".") -- for future versions

    if tes3mp.GetServerVersion() ~= "0.6.1" then
        tes3mp.LogMessage(3, "The server or script is outdated!")
        tes3mp.StopServer(1)
    end

    myMod.InitializeWorld()
    myMod.PushPlayerList(Players)

    LoadBanList()
    LoadPluginList()
	LoadTokenList()
	
	local data1 = {"-11, 15", -89353, 128479, 110, 1.86} -- Ald Velothi
	local data2 = {"-3, -3", -20986, -17794, 865, -0.87} -- Balmora
	local data3 = {"-2, 2", -12238, 20554, 1514, -2.77} -- Caldera
	local data4 = {"7, 22", 62629, 185197, 131, -2.83} -- Dagon Fel
	local data5 = {"2, -13", 20769, -103041, 107, -0.87} -- Ebonheart
	local data6 = {"-8, 3", -58009, 26377, 52, -1.49} -- Gnaar Mok
	local data7 = {"-11, 11", -86910, 90044, 1021, 0.44} -- Gnisis
	local data8 = {"-6, -5", -49093, -40154, 78, 0.94} -- Hla Oad
	local data9 = {"-9, 17", -69502, 142754, 50, 2.89} -- Khuul
	local data10 = {"-3, 12", -22622, 101142, 1725, 0.28} -- Maar Gan
	local data11 = {"12, -8", 103871, -58060, 1423, 2.2} -- Molag Mar
	local data12 = {"0, -7", 2341, -56259, 1477, 2.13} -- Pelagiad
	local data13 = {"17, 4", 141415, 39670, 213, 2.47} -- Sadrith Mora
	local data14 = {"6, -6", 52855, -48216, 897, 2.36} -- Suran
	local data15 = {"14, 4", 122576, 40955, 59, 1.16} -- Tel Aruhn
	local data16 = {"14, -13", 119124, -101518, 51, 3.08} -- Tel Branora
	local data17 = {"13, 14", 106608, 115787, 53, -0.39} -- Tel Mora
	local data18 = {"3, -10", 36412, -74454, 59, -1.66} -- Vivec
	local data19 = {"11, 14", 101402, 114893, 158, -2.03} -- Vos
	spawnTable = {data1, data2, data3, data4, data5, data6, data7, data8, data9, data10, data11, data12, data13, data14, data15, data16, data17, data18, data19}
	spawnTable = TableShuffle(spawnTable)
end
```

Find and replace:
```
        elseif (cmd[1] == "greentext" or cmd[1] == "gt") and cmd[2] ~= nil then
            local message = myMod.GetChatName(pid) .. ": " .. color.GreenText .. ">" .. tableHelper.concatenateFromIndex(cmd, 2) .. "\n"
            tes3mp.SendMessage(pid, message, true)

		else
            local message = "Not a valid command. Type /help for more info.\n"
            tes3mp.SendMessage(pid, color.Error..message..color.Default, false)
        end
```
with:
```
        elseif (cmd[1] == "greentext" or cmd[1] == "gt") and cmd[2] ~= nil then
            local message = myMod.GetChatName(pid) .. ": " .. color.GreenText .. ">" .. tableHelper.concatenateFromIndex(cmd, 2) .. "\n"
            tes3mp.SendMessage(pid, message, true)

		elseif cmd[1] == "addtoken" and cmd[2] ~= nil and admin then
			local ntoken = tonumber(cmd[3])
			ccScript.TokenAdd(pid, cmd[2], ntoken)
			
		elseif cmd[1] == "checktoken" then
			local ident = 0
			
			if admin then
				ident = 1
			end
			ccScript.TokenCheck(pid, cmd[2], ident)
			
		elseif cmd[1] == "claimtoken" then
			ccScript.TokenClaim(pid)
		
		elseif cmd[1] == "lottery" then
			local ident = 0
			
			if admin then
				ident = 1
			end
			ccScript.LotteryHandler(pid, ident)
		
        elseif cmd[1] == "perks" then
            local text = perkstext .. "\n";
            tes3mp.MessageBox(pid, -1, text)
		
		elseif cmd[1] == "punish" and cmd[2] ~= nil and moderator then
			ccScript.PunishOcean(pid, cmd[2])
			
		elseif cmd[1] == "roll" then
			ccScript.Roll(pid)

		elseif cmd[1] == "setcreature" and cmd[2] ~= nil then
			
			if cmd[2] == "list" then
				tes3mp.MessageBox(pid, -1, creaturetext)
			else
				local ident = 0
				
				if moderator then
					ident = 1
				end
				ccScript.SetCreature(pid, cmd[2], ident)
			end

		elseif cmd[1] == "setgender" and cmd[2] ~= nil then
			local ident = 0
			
			if admin then
				ident = 1
			end
			ccScript.GenderChanger(pid, cmd[2], ident)
			
		elseif cmd[1] == "sethair" and cmd[2] ~= nil then
			local ident = 0
			
			if admin then
				ident = 1
			end
			ccScript.HairChanger(pid, cmd[2], ident)
			
		elseif cmd[1] == "sethead" and cmd[2] ~= nil then
			local ident = 0
			
			if admin then
				ident = 1
			end
			ccScript.HeadChanger(pid, cmd[2], ident)			

		elseif cmd[1] == "smsg" and cmd[2] ~= nil and moderator then
            local message = color.Orange .. "SERVER: " .. tableHelper.concatenateFromIndex(cmd, 2) .. "\n"
            tes3mp.SendMessage(pid, message, true)

		else
            local message = "Not a valid command. Type /help for more info.\n"
            tes3mp.SendMessage(pid, color.Error..message..color.Default, false)
        end
```

Create a new line at the end of the document and paste this:
```
-- Thanks to http://gamebuildingtools.com/using-lua/shuffle-table-lua
function TableShuffle(t)
	local n = #t -- gets the length of the table 
	
	while n > 2 do -- only run if the table has more than 1 element
		local k = math.random(n) -- get a random number
		t[n], t[k] = t[k], t[n]
		n = n - 1
	end
	return t
end
```

# Changes to .../scripts/myMod.lua
Open the **myMod.lua** file and make the following changes (use CTRL-F or something similar):

Find and replace:
```
require("actionTypes")
```
with:
```
require("actionTypes")
ccScript = require("ccScript")
```

Find and replace:
```
Methods.OnPlayerEndCharGen = function(pid)
    if Players[pid] ~= nil then
        Players[pid]:EndCharGen()
    end
end
```
with:
```
Methods.OnPlayerEndCharGen = function(pid)
    if Players[pid] ~= nil then
        Players[pid]:EndCharGen()
		ccScript.SpawnPosition(pid)
		ccScript.SpawnItems(pid)
    end
end
```