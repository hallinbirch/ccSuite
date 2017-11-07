---------------------------
-- ccScript by Texafornian
--
-- Many thanks to:
-- * ppsychrite
-- * Reinhart
---------------------------

Methods = {}

math.randomseed( os.time() )

------------------
-- METHODS SECTION
------------------

Methods.GenderChanger = function(pid, gender, priv)
	local hair = ""
	local head = ""
	local ipAddress = tes3mp.GetIP(pid)
	local message = ""
	local playerName = Players[pid].name
	local race = string.lower(Players[pid].data.character.race)
	
	tes3mp.LogMessage(2, "++++ " .. playerName .. " (" .. race .. ") tried to use /setgender " .. gender .. " ++++")
	
	if type(tonumber(gender)) ~= "number" or tonumber(gender) < 0 or tonumber(gender) > 1 then
		message = color.Gold .. "Please choose either 0 (female) or 1 (male).\n"
		tes3mp.SendMessage(pid, message, false)
		return false
	end
	
	if race == "argonian" or race == "khajiit" then -- These races have different hair ID format
	
		if gender == 1 then
			hair = "b_n_" .. race .. "_m_hair01" -- Assign default head and hair styles of 01
			head = "b_n_" .. race .. "_m_head_01"
		else
			hair = "b_n_" .. race .. "_f_hair01"
			head = "b_n_" .. race .. "_f_head_01"
		end
	else
	
		if gender == 1 then
			hair = "b_n_" .. race .. "_m_hair_01"
			head = "b_n_" .. race .. "_m_head_01"
		else
			hair = "b_n_" .. race .. "_f_hair_01"
			head = "b_n_" .. race .. "_f_head_01"
		end
	end
	
	if gender == Players[pid].data.character.gender then -- Check whether player already has this gender
		message = color.Gold .. "You already have that gender.\n"
		tes3mp.SendMessage(pid, message, false)
		return false
	end
	
	nilTokenCheck(playerName, ipAddress)
	
	if priv == 0 then
		local tokenCost = 1
		
		if TokenCalc(pid, ipAddress, tokenCost) == false then
			return false
		end
	end
	
	Players[pid].data.character.gender = gender
	Players[pid].data.character.hair = hair
	Players[pid].data.character.head = head
	-- Players[pid]:LoadCharacter() - Sets level to 1 but could be fixed via setcreature solution
	message = color.Gold .. "Your gender has been switched.\nReconnect to the server to apply the change.\n"
	tes3mp.SendMessage(pid, message, false)
end

Methods.HeadChanger = function(pid, pick, priv)
	local gender = Players[pid].data.character.gender
	local head = Players[pid].data.character.head
	local ipAddress = tes3mp.GetIP(pid)
	local message = ""
	local playerName = Players[pid].name
	local race = string.lower(Players[pid].data.character.race)
	
	tes3mp.LogMessage(2, "++++ " .. playerName .. " (" .. race .. ") tried to use /sethead " .. pick .. " ++++")
	
	if type(tonumber(pick)) ~= "number" then
		message = color.Gold .. "Please use a number in /sethead.\n"
		tes3mp.SendMessage(pid, message, false)
		return false
	end
	
	if race == "argonian" then
	
		if tonumber(pick) < 1 or tonumber(pick) > 3 then
			message = color.Gold .. "Please choose a number between 1 and 3.\n"
			tes3mp.SendMessage(pid, message, false)
			return false
		end
	elseif race == "breton" or race == "nord" then
		
		if tonumber(pick) < 1 or tonumber(pick) > 8 then
			message = color.Gold .. "Please choose a number between 1 and 8.\n"
			tes3mp.SendMessage(pid, message, false)
			return false
		end
	elseif race == "dark elf" then

		if gender == 1 then
		
			if tonumber(pick) < 1 or tonumber(pick) > 17 then
				message = color.Gold .. "Please choose a number between 1 and 17.\n"
				tes3mp.SendMessage(pid, message, false)
				return false
			end
		else
		
			if tonumber(pick) < 1 or tonumber(pick) > 10 then
				message = color.Gold .. "Please choose a number between 1 and 10.\n"
				tes3mp.SendMessage(pid, message, false)
				return false
			end
		end
		
	elseif race == "high elf" or race == "redguard" then
		
		if tonumber(pick) < 1 or tonumber(pick) > 6 then
			message = color.Gold .. "Please choose a number between 1 and 6.\n"
			tes3mp.SendMessage(pid, message, false)
			return false
		end
	elseif race == "imperial" then
		
		if tonumber(pick) < 1 or tonumber(pick) > 7 then
			message = color.Gold .. "Please choose a number between 1 and 7.\n"
			tes3mp.SendMessage(pid, message, false)
			return false
		end
	elseif race == "khajiit" then
		
		if tonumber(pick) < 1 or tonumber(pick) > 4 then
			message = color.Gold .. "Please choose a number between 1 and 4.\n"
			tes3mp.SendMessage(pid, message, false)
			return false
		end
	elseif race == "orc" then

		if gender == 1 then
		
			if tonumber(pick) < 1 or tonumber(pick) > 4 then
				message = color.Gold .. "Please choose a number between 1 and 4.\n"
				tes3mp.SendMessage(pid, message, false)
				return false
			end
		else
		
			if tonumber(pick) < 1 or tonumber(pick) > 3 then
				message = color.Gold .. "Please choose a number between 1 and 3.\n"
				tes3mp.SendMessage(pid, message, false)
				return false
			end
		end
	elseif race == "wood elf" then

		if gender == 1 then
		
			if tonumber(pick) < 1 or tonumber(pick) > 8 then
				message = color.Gold .. "Please choose a number between 1 and 8.\n"
				tes3mp.SendMessage(pid, message, false)
				return false
			end
		else
		
			if tonumber(pick) < 1 or tonumber(pick) > 6 then
				message = color.Gold .. "Please choose a number between 1 and 6.\n"
				tes3mp.SendMessage(pid, message, false)
				return false
			end
		end
	else
		message = color.Red .. "ERROR in player's race; contact the admin!\n"
		tes3mp.SendMessage(pid, message, false)
		tes3mp.LogMessage(2, "++++ " .. playerName .. " has error in data.character.race! ++++" )
		return false
	end
	
	if tonumber(pick) < 10 then -- Make sure head ID is in 00 format
		pick = "0" .. pick
	end
	
	if gender == 1 then
		head = "b_n_" .. race .. "_m_head_" .. pick
	else
		head = "b_n_" .. race .. "_f_head_" .. pick
	end
	
	if head == Players[pid].data.character.head then -- Check whether player already has this head
		message = color.Gold .. "You already have that head.\n"
		tes3mp.SendMessage(pid, message, false)
		return false
	end
	
	nilTokenCheck(playerName, ipAddress)
	
	if priv == 0 then
		local tokenCost = 1
		
		if TokenCalc(pid, ipAddress, tokenCost) == false then
			return false
		end
	end
	
	Players[pid].data.character.head = head
	-- Players[pid]:LoadCharacter() - Sets level to 1 but could be fixed via setcreature solution
	message = color.Gold .. "Your head is now " .. head .. ".\nReconnect to the server to apply the change.\n"
	tes3mp.SendMessage(pid, message, false)
end

Methods.HairChanger = function(pid, pick, priv)
	local gender = Players[pid].data.character.gender
	local hair = Players[pid].data.character.hair
	local ipAddress = tes3mp.GetIP(pid)
	local message = ""
	local playerName = Players[pid].name
	local race = string.lower(Players[pid].data.character.race)
	
	tes3mp.LogMessage(2, "++++ " .. playerName .. " (" .. race .. ") tried to use /sethair " .. pick .. " ++++")
	
	if type(tonumber(pick)) ~= "number" then
		message = color.Gold .. "Please use a number in /sethair.\n"
		tes3mp.SendMessage(pid, message, false)
		return false
	end
	
	if race == "argonian" or race == "redguard" or race == "wood elf" then
	
		if gender == 1 then
		
			if tonumber(pick) < 1 or tonumber(pick) > 6 then
				message = color.Gold .. "Please choose a number between 1 and 6.\n"
				tes3mp.SendMessage(pid, message, false)
				return false
			end
		else
		
			if tonumber(pick) < 1 or tonumber(pick) > 5 then
				message = color.Gold .. "Please choose a number between 1 and 5.\n"
				tes3mp.SendMessage(pid, message, false)
				return false
			end
		end
	elseif race == "breton" or race == "orc" or race == "khajiit" then
		
		if tonumber(pick) < 1 or tonumber(pick) > 5 then
			message = color.Gold .. "Please choose a number between 1 and 5.\n"
			tes3mp.SendMessage(pid, message, false)
			return false
		end
	elseif race == "dark elf" then

		if gender == 1 then
		
			if tonumber(pick) < 1 or tonumber(pick) > 26 then
				message = color.Gold .. "Please choose a number between 1 and 26.\n"
				tes3mp.SendMessage(pid, message, false)
				return false
			end
		else
		
			if tonumber(pick) < 1 or tonumber(pick) > 24 then
				message = color.Gold .. "Please choose a number between 1 and 24.\n"
				tes3mp.SendMessage(pid, message, false)
				return false
			end
		end
		
	elseif race == "high elf" then
		
		if gender == 1 then
		
			if tonumber(pick) < 1 or tonumber(pick) > 5 then
				message = color.Gold .. "Please choose a number between 1 and 5.\n"
				tes3mp.SendMessage(pid, message, false)
				return false
			end
		else
		
			if tonumber(pick) < 1 or tonumber(pick) > 4 then
				message = color.Gold .. "Please choose a number between 1 and 4.\n"
				tes3mp.SendMessage(pid, message, false)
				return false
			end
		end
	elseif race == "imperial" then
		
		if gender == 1 then
		
			if tonumber(pick) < 1 or tonumber(pick) > 9 then
				message = color.Gold .. "Please choose a number between 1 and 9.\n"
				tes3mp.SendMessage(pid, message, false)
				return false
			end
		else
		
			if tonumber(pick) < 1 or tonumber(pick) > 7 then
				message = color.Gold .. "Please choose a number between 1 and 7.\n"
				tes3mp.SendMessage(pid, message, false)
				return false
			end
		end
	elseif race == "nord" then
		
		if gender == 1 then
		
			if tonumber(pick) < 1 or tonumber(pick) > 7 then
				message = color.Gold .. "Please choose a number between 1 and 7.\n"
				tes3mp.SendMessage(pid, message, false)
				return false
			end
		else
		
			if tonumber(pick) < 1 or tonumber(pick) > 5 then
				message = color.Gold .. "Please choose a number between 1 and 5.\n"
				tes3mp.SendMessage(pid, message, false)
				return false
			end
		end
	else
		message = color.Red .. "ERROR in player's race; contact the admin!\n"
		tes3mp.SendMessage(pid, message, false)
		tes3mp.LogMessage(2, "++++ " .. playerName .. " has error in data.character.race! ++++" )
		return false
	end
	
	if tonumber(pick) < 10 then -- Make sure hair ID is in 00 format
		pick = "0" .. pick
	end
	
	if race == "argonian" or race == "khajiit" then -- These races have different ID format
	
		if gender == 1 then
			hair = "b_n_" .. race .. "_m_hair" .. pick
		else
			hair = "b_n_" .. race .. "_f_hair" .. pick
		end
	else
		if gender == 1 then
			hair = "b_n_" .. race .. "_m_hair_" .. pick
		else
			hair = "b_n_" .. race .. "_f_hair_" .. pick
		end
	end
	
	if hair == Players[pid].data.character.head then -- Check whether player already has this hair
		message = color.Gold .. "You already have that hair.\n"
		tes3mp.SendMessage(pid, message, false)
		return false
	end
	
	nilTokenCheck(playerName, ipAddress)
	
	if priv == 0 then
		local tokenCost = 1
		
		if TokenCalc(pid, ipAddress, tokenCost) == false then
			return false
		end
	end
	
	Players[pid].data.character.hair = hair
	-- Players[pid]:LoadCharacter() - Sets level to 1 but could be fixed via setcreature solution
	message = color.Gold .. "Your hair is now " .. hair .. ".\nReconnect to the server to apply the change.\n"
	tes3mp.SendMessage(pid, message, false)
end

Methods.LotteryHandler = function(pid, priv) -- Used to generate prizes for tokens
	local playerName = Players[pid].name
	local item = {}
	local message = ""
	local ipAddress = tes3mp.GetIP(pid)
	
	math.random(); math.random() -- Try to improve RNG
	local rando = math.random(1, 145)
	
	tes3mp.LogMessage(2, "++++ " .. playerName .. " uses /lottery with rando = " .. rando .. " ++++")
	
	nilTokenCheck(playerName, ipAddress)
		
	if priv == 0 then
		local tokenCost = 1
		
		if TokenCalc(pid, ipAddress, tokenCost) == false then
			return false
		end
	end
		
	if rando <= 42 then
		local iCount = 1 -- Var used to increase count if item exists in inventory
		local itemIs = ""
		
		if rando <= 5 then
			local iCount = 2
			item = { refId = "ingred_bread_01_UNI3", count = 2, charge = -1 }
			message = color.Gold .. "LOTTERY: You've won some Muffins!\n"
		elseif rando >= 6 and rando <= 10 then
			local iCount = 2
			
			if rando <= 8 then
				item = { refId = "ingred_scrib_jelly_02", count = 2, charge = -1 }
			else
				item = { refId = "ingred_heartwood_01", count = 2, charge = -1 }
			end
			message = color.Gold .. "LOTTERY: You've won some rare ingredients!\n"
		elseif rando >= 11 and rando <= 36 then
			
			if rando >= 11 and rando <= 15 then
			
				if rando == 11 then
					item = { refId = "key_Andas_tomb", count = 1, charge = -1 }
				elseif rando == 12 then
					item = { refId = "key_aurane1", count = 1, charge = -1 }
				elseif rando == 13 then
					item = { refId = "key_Falas_chest", count = 1, charge = -1 }
				elseif rando == 14 then
					item = { refId = "key_j'zhirr", count = 1, charge = -1 }
				elseif rando == 15 then
					item = { refId = "key_sethan", count = 1, charge = -1 }
				end	
				itemIs = "key"
			elseif rando >= 16 and rando <= 19 then
			
				if rando == 16 then
					item = { refId = "apparatus_sm_alembic_01", count = 1, charge = -1 }
				elseif rando == 17 then
					item = { refId = "apparatus_sm_calcinator_01", count = 1, charge = -1 }
				elseif rando == 18 then
					item = { refId = "apparatus_sm_mortar_01", count = 1, charge = -1 }
				elseif rando == 19 then
					item = { refId = "apparatus_sm_retort_01", count = 1, charge = -1 }
				end
				itemIs = "alchemy tool"
			elseif rando == 20 or rando == 21 then
			
				if rando == 20 then
					item = { refId = "veloths_shield", count = 1, charge = 15 }
				elseif rando == 21 then
					item = { refId = "steel_towershield_ancient", count = 1, charge = -1 }
				end
				itemIs = "shield"
			elseif rando >= 22 and rando <= 30 then
			
				if rando == 22 then
					item = { refId = "BM_hunter_battleaxe_unique", count = 1, charge = -1 }
				elseif rando == 23 then
					item = { refId = "daedric_club_tgdc", count = 1, charge = -1 }
				elseif rando == 24 then
					item = { refId = "herder_crook", count = 1, charge = 80 }
				elseif rando == 25 then
					item = { refId = "iron fork", count = 1, charge = -1 }
				elseif rando == 26 then
					item = { refId = "axe_queen_of_bats_unique", count = 1, charge = 500 }
				elseif rando == 27 then
					item = { refId = "staff_of_llevule", count = 1, charge = 50 }
				elseif rando == 28 then
					item = { refId = "ebony_dagger_mehrunes", count = 1, charge = -1 }
				elseif rando == 29 then
					item = { refId = "clutterbane", count = 1, charge = 10 }
				elseif rando == 30 then
					item = { refId = "throwing knife of sureflight", count = 7, charge = -1 }
				end
				itemIs = "weapon"
			elseif rando >= 31 and rando <= 35 then
				
				if rando == 31 then
					item = { refId = "slippers_of_doom", count = 1, charge = 120 }
				elseif rando == 32 then
					item = { refId = "mandas_locket", count = 1, charge = -1 }
				elseif rando == 33 then
					item = { refId = "fenrick's doorjam ring", count = 1, charge = 5 }
				elseif rando == 34 then
					item = { refId = "Recall_Ring", count = 1, charge = 90 }
				elseif rando == 35 then
					item = { refId = "common_ring_tsiya", count = 1, charge = -1 }
				end
				itemIs = "piece of clothing"
			elseif rando == 36 then
				item = { refId = "Misc_flask_grease", count = 1, charge = -1 }
				itemIs = "Jar of Grease"
			end
			message = color.Gold .. "LOTTERY: You've won a unique " .. itemIs .. "!\n"
		elseif rando >= 37 and rando <= 40 then
			
			if rando == 37 then
				item = { refId = "fur_colovian_helm_white", count = 1, charge = -1 }
				itemIs = "hat"
			elseif rando == 38 then
				item = { refId = "robe of burdens", count = 1, charge = 75 }
				itemIs = "robe"
			elseif rando == 39 then
				item = { refId = "skeleton_key", count = 1, charge = -1 }
				itemIs = "lockpick"
			elseif rando == 40 then
				item = { refId = "light_com_lantern_02_inf", count = 1, charge = -1 }
				itemIs = "lantern"
			end
			message = color.Gold .. "LOTTERY: You've won a rare " .. itemIs .. "!\n"
		elseif rando == 41 then
			item = { refId = "misc_com_plate_02_tgrc", count = 1, charge = -1 }
			itemIs = "Blue Plate"
			message = color.Gold .. "LOTTERY: You've won a " .. itemIs .. "! This one is nice.\n"
		elseif rando == 42 then
			item = { refId = "misc_com_plate_06_tgrc", count = 1, charge = -1 }
			itemIs = "Brown Plate"
			message = color.Gold .. "LOTTERY: You've won a " .. itemIs .. "! This one seems to last longer.\n"
		end
		
		if Players[pid].data.inventory.refId ~= nil then -- Check whether item exists in inventory
			local tempCount = Players[pid].data.inventory.count + iCount -- If not, increase its count by proper amount
			Players[pid].data.inventory.count = tempCount
		else
			table.insert(Players[pid].data.inventory, item) 
		end
		Players[pid]:LoadInventory()
		Players[pid]:LoadEquipment()

	elseif rando >= 43 and rando <= 79 then
		local tokenCounter = 0
		
		if rando == 43 then
			tokenCounter = tokenList.players[ipAddress].tokens + 25
			message = color.Gold .. "LOTTERY: You've won **25** tokens and now have " .. tokenCounter .. " token(s).\n"
		elseif rando == 44 or rando == 45 then
			tokenCounter = tokenList.players[ipAddress].tokens + 10
			message = color.Gold .. "LOTTERY: You've won *10* tokens and now have " .. tokenCounter .. " token(s).\n"
		elseif rando >= 46 and rando <= 49 then
			tokenCounter = tokenList.players[ipAddress].tokens + 5
			message = color.Gold .. "LOTTERY: You've won 5 tokens and now have " .. tokenCounter .. " token(s).\n"
		elseif rando >= 50 and rando <= 59 then
			tokenCounter = tokenList.players[ipAddress].tokens + 2
			message = color.Gold .. "LOTTERY: You've won 2 tokens and now have " .. tokenCounter .. " token(s).\n"
		else
			tokenCounter = tokenList.players[ipAddress].tokens + 1
			message = color.Gold .. "LOTTERY: You've won a token and now have " .. tokenCounter .. " token(s).\n"
		end
		
		tokenList.players[ipAddress].tokens = tokenCounter
		jsonInterface.save("tokenlist.json", tokenList)
	else
		message = color.Gold .. "LOTTERY: You didn't win anything this time...\n"
	end
	tes3mp.SendMessage(pid, message, false)
end

Methods.PunishOcean = function(pid, targetPlayer) -- Used to send a player into the ocean
	local targetPlayerName = Players[tonumber(targetPlayer)].name
	local message = color.Orange .. "SERVER: " .. targetPlayerName .. " is going for a swim.\n"
	
	tes3mp.SetExteriorCell(targetPlayer, -15, -7)
	tes3mp.SendCell(targetPlayer)
	
	tes3mp.SetPos(targetPlayer, -115000, -55000, 0)
	tes3mp.SetRot(targetPlayer, 0, 0)
	tes3mp.SendPos(targetPlayer)
	
	tes3mp.SendMessage(pid, message, true)
end

Methods.Roll = function(pid) -- Used to roll the dice
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

Methods.SetCreature = function(pid, creature, priv) -- Used to set a creature as a player's model
	local creature = string.lower(creature)
	local creatureset = {"alit", "ancestor_ghost", "ascended_sleeper", "ash_ghoul", "ash_slave", "ash_zombie", "atronach_flame", "atronach_frost", "atronach_storm", "BM_bear_black", "BM_bear_brown", "BM_bear_snow_unique", "BM_draugr01", "BM_frost_boar", "bm_frost_giant", "BM_horker", "BM_ice_troll", "BM_riekling", "BM_spriggan", "BM_wolf_grey", "BM_wolf_red", "BM_wolf_skeleton", "BM_wolf_snow_unique", "bonelord_summon", "bonewalker_summon", "Bonewalker_Greater_summ", "clannfear_summon", "cliff racer", "corprus_lame", "corprus_stalker", "daedroth_summon", "dremora", "durzog_wild", "dwarven ghost", "fabricant_hulking", "fabricant_summon", "goblin_bruiser", "guar", "guar_white_unique", "hunger_summon", "kagouti", "kwama forager", "kwama warrior", "kwama worker", "mudcrab", "netch_betty", "netch_bull", "nix-hound", "ogrim", "rat", "scamp", "scrib", "shalk", "skeleton_summon", "vivec_god", "winged twilight"}
	local playerName = Players[pid].name
	local message = ""
	local ipAddress = tes3mp.GetIP(pid)
	
	nilTokenCheck(playerName, ipAddress)

	if creature == "bear_black" then
		creature = "BM_bear_black"
	elseif creature == "bear_brown" then
		creature = "BM_bear_brown"
	elseif creature == "bear_snow" then
		creature = "BM_bear_snow_unique"
	elseif creature == "boar" then
		creature = "BM_frost_boar"
	elseif creature == "bonelord" then
		creature = "bonelord_summon"
	elseif creature == "bonewalker_lesser" then
		creature = "bonewalker_summon"
	elseif creature == "bonewalker_greater" then
		creature = "Bonewalker_Greater_summ"
	elseif creature == "clannfear" then
		creature = "clannfear_summon"
	elseif creature == "cliff_racer" then
		creature = "cliff racer"
	elseif creature == "daedroth" then
		creature = "daedroth_summon"
	elseif creature == "draugr" then
		creature = "BM_draugr01"
	elseif creature == "durzog" then
		creature = "durzog_wild"
	elseif creature == "dwemer_ghost" then
		creature = "dwarven ghost"
	elseif creature == "fabricant_hulking" then
		creature = "fabricant_hulking"
	elseif creature == "fabricant_verminous" then
		creature = "fabricant_summon"
	elseif creature == "frost_giant" then
		creature = "bm_frost_giant"
	elseif creature == "goblin" then
		creature = "goblin_bruiser"
	elseif creature == "guar_white" then
		creature = "guar_white_unique"
	elseif creature == "ice_troll" then
		creature = "BM_ice_troll"
	elseif creature == "horker" then
		creature = "BM_horker"
	elseif creature == "hunger" then
		creature = "hunger_summon"
	elseif creature == "kwama_forager" then
		creature = "kwama forager"
	elseif creature == "kwama_warrior" then
		creature = "kwama warrior"
	elseif creature == "kwama_worker" then
		creature = "kwama worker"
	elseif creature == "riekling" then
		creature = "BM_riekling"
	elseif creature == "skeleton" then
		creature = "skeleton_summon"
	elseif creature == "spriggan" then
		creature = "BM_spriggan"
	elseif creature == "vivec" then
		creature = "vivec_god"
	elseif creature == "winged_twilight" then
		creature = "winged twilight"
	elseif creature == "wolf_bone" then
		creature = "BM_wolf_skeleton"
	elseif creature == "wolf_gray" then
		creature = "BM_wolf_grey"
	elseif creature == "wolf_red" then
		creature = "BM_wolf_red"
	elseif creature == "wolf_snow" then
		creature = "BM_wolf_snow_unique"
	end
	
	tes3mp.LogMessage(2, "++++ " .. playerName .. " tried to use /setcreature " .. creature .. " ++++")
	
	if hasValue(creatureset, creature) then
	
		if priv == 0 then
			local tokenCost = 1
			
			if TokenCalc(pid, ipAddress, tokenCost) == false then
				return false
			end
		end
	
		-- Store current player info 
		local tempAttrs = Players[pid].data.attributes
		local tempStats = Players[pid].data.stats
		local tempSkills = Players[pid].data.skills
		local tempSpells = Players[pid].data.spellbook
		
		-- Creature model cmd sets player info to level 1
		tes3mp.SetCreatureModel(pid, creature, false)
		tes3mp.SendBaseInfo(pid)
		
		-- Restore player's info
		Players[pid].data.attributes = tempAttrs
		Players[pid].data.stats = tempStats
		Players[pid].data.skills = tempSkills
		Players[pid].data.spellbook = tempSpells
		tes3mp.SendAttributes(pid)
		tes3mp.SendStatsDynamic(pid)
		tes3mp.SendSkills(pid)
		tes3mp.SendLevel(pid)
		tes3mp.SendSpellbookChanges(pid)
		
		-- Equipment need to be re-equipped for bonuses to take effect again
		Players[pid]:LoadEquipment()
		
		message = color.Gold .. "You now appear as a " .. creature .. " to other players.\n"
	else
		message = "That creature ID either doesn't exist or is currently unsupported.\n"
	end
	tes3mp.SendMessage(pid, message, false)
end

Methods.SpawnItems = function(pid) -- Randomized clothes for new players + 150 gold
	local item = {}
	local race = string.lower(Players[pid].data.character.race)
	local spawnGold = { refId = "gold_001", count = 150, charge = -1 }
	local spawnPants = "common_pants_0"
	local spawnShirt = "common_shirt_0"
	local spawnSkirt = "common_skirt_0"
	local spawnShoes = "common_shoes_0"

	math.random(); math.random() -- Try to improve RNG
	local rando = tostring(math.random(1,7))
	
	Players[pid].data.inventory = {}
	Players[pid].data.equipment = {}
	
	tes3mp.LogMessage(2, "++++ Adding gold to new character ++++")
	table.insert(Players[pid].data.inventory, spawnGold)
	
	tes3mp.LogMessage(2, "++++ Randomizing new player's clothes ++++")
	spawnShirt = spawnShirt .. rando
	item = { refId = spawnShirt, count = 1, charge = -1 }
	Players[pid].data.equipment[8] = item
	
	if Players[pid].data.character.gender == 0 then
		rando = tostring(math.random(1,5))
		spawnSkirt = spawnSkirt .. rando
		item = { refId = spawnSkirt, count = 1, charge = -1 }
		Players[pid].data.equipment[10] = item
	else
		rando = tostring(math.random(1,7))
		spawnPants = spawnPants .. rando
		item = { refId = spawnPants, count = 1, charge = -1 }
		Players[pid].data.equipment[9] = item
	end
	
	if race ~= "argonian" and race ~= "khajiit" then
		rando = tostring(math.random(1,5))
		spawnShoes = spawnShoes .. rando
		item = { refId = spawnShoes, count = 1, charge = -1 }
		Players[pid].data.equipment[7] = item
	end
	
	Players[pid]:LoadInventory()
	Players[pid]:LoadEquipment()
end

Methods.SpawnPosition = function(pid) -- Randomized spawn position based on global spawnTable in server.lua
	local tempRef = pid + 1 -- Needed for PID "0" because LUA tables start at "1"
	
	tes3mp.LogMessage(2, "++++ Spawning new player in cell ... ++++")
	tes3mp.LogMessage(2, "++++ (" .. spawnTable[tempRef][1] .. ") ++++")
	tes3mp.SetCell(pid, spawnTable[tempRef][1])
	tes3mp.SendCell(pid)
	tes3mp.SetPos(pid, spawnTable[tempRef][2], spawnTable[tempRef][3], spawnTable[tempRef][4])
	tes3mp.SetRot(pid, 0, spawnTable[tempRef][5])
	tes3mp.SendPos(pid)
end

Methods.TokenAdd = function(pid, pid2, numTokens) -- Used to manually give a player tokens
	
	if myMod.CheckPlayerValidity(pid, pid2) then
		local playerName = Players[tonumber(pid2)].name
		local tokenCounter = 0
		local message = ""
		local ipAddress = tes3mp.GetIP(pid2)
		
		nilTokenCheck(playerName, ipAddress)
		
		if numTokens ~= nil then
			tokenCounter = tokenList.players[ipAddress].tokens + numTokens
			message = color.Gold .. "SERVER: " .. playerName .. " has received " .. numTokens .. " token(s)!\n"
		else
			tokenCounter = tokenList.players[ipAddress].tokens + 1
			message = color.Gold .. "SERVER: " .. playerName .. " has received a token!\n"
		end
		
		tokenList.players[ipAddress].tokens = tokenCounter
		jsonInterface.save("tokenlist.json", tokenList)
		tes3mp.SendMessage(pid, message, true)
	end
end

Methods.TokenCheck = function(pid, pid2, priv) -- Used to check number of tokens
	local tokenCounter = 0
	local message = ""
	
	if pid2 ~= nil then
		if priv == 1 then
			if myMod.CheckPlayerValidity(pid, pid2) then
				local playerName = Players[tonumber(pid2)].name
				local ipAddress = tes3mp.GetIP(pid2)
				
				nilTokenCheck(playerName, ipAddress)
				
				tokenCounter = tokenList.players[ipAddress].tokens
				
				if tokenCounter <= 0 then
					message = color.Gold .. playerName .. " doesn't have any tokens.\n"
				else
					message = color.Gold .. playerName .. " has " .. tokenCounter .. " token(s).\n"
				end
			end
		else
			message = color.Gold .. "Try /checktoken without any numbers.\n"
		end
	else
		local playerName = Players[pid].name
		local ipAddress = tes3mp.GetIP(pid)

		nilTokenCheck(playerName, ipAddress)
		
		tokenCounter = tokenList.players[ipAddress].tokens
		
		if tokenCounter <= 0 then
			message = color.Gold .. "You don't have any tokens.\n"
		else
			message = color.Gold .. "You have " .. tokenCounter .. " token(s). Type /perks for a list of commands that you can use.\n"
		end
	end
	tes3mp.SendMessage(pid, message, false)
end

Methods.TokenClaim = function(pid) -- Used to give one token per day
	local playerName = Players[pid].name
	local message = ""
	local timeString = os.date( "%d/%m/%Y" )
	local ipAddress = tes3mp.GetIP(pid)
	
	nilTokenCheck(playerName, ipAddress)
	
	local timeStored = tokenList.players[ipAddress].claimdate
	local tokenCounter = tokenList.players[ipAddress].tokens
	
	if timeStored == "" or timeStored ~= timeString then
		tokenList.players[ipAddress].claimdate = timeString
		tokenCounter = tokenList.players[ipAddress].tokens + 1
		tokenList.players[ipAddress].tokens = tokenCounter
		jsonInterface.save("tokenlist.json", tokenList)
		message = color.Gold .. "You've claimed your daily token. Type /perks for a list of commands that you can use.\n"
		tes3mp.LogMessage(2, "++++ " .. playerName .. " with IP = " .. ipAddress .. " uses /claimtoken ++++")
	else
		message = color.Gold .. "You've already claimed your daily token.\n"
	end
	tes3mp.SendMessage(pid, message, false)
end

--------------------
-- FUNCTIONS SECTION
--------------------

function hasValue(tab, val) -- Used to ensure correct IDs are used
	for index, value in ipairs(tab) do
	
		if value == val then
			return true
		end
	end
	return false
end

function nilTokenCheck(playerName, ipAddress) -- Used to create and manage entries in tokenlist.json
	
	-- If this IP address entry doesn't exist, then make new blank entry
	if tokenList.players[ipAddress] == nil then 
		local player = {}
		player.tokens = 0
		player.claimdate = ""
		player.names = {}
		tokenList.players[ipAddress] = player
		jsonInterface.save("tokenlist.json", tokenList)
	-- If this IP address does exist check whether player has been logged
	else 
		-- If this IP address already exists for another character, then add this character to it
		if tableHelper.containsValue(tokenList.players[ipAddress].names, playerName) == false then
			table.insert(tokenList.players[ipAddress].names, playerName)
			jsonInterface.save("tokenlist.json", tokenList)
		end
	end
end

function TokenCalc(pid, ipAddress, tokenCost) -- Used to check number of tokens before perk is applied
	local message = ""
	local tokenCounter = tokenList.players[ipAddress].tokens
	
	if tokenCounter >= 1 then
		tokenCounter = tokenList.players[ipAddress].tokens - tokenCost
		tokenList.players[ipAddress].tokens = tokenCounter
		jsonInterface.save("tokenlist.json", tokenList)
		message = color.Gold .. "You use a token and now have " .. tokenCounter .. " token(s).\n"
		tes3mp.SendMessage(pid, message, false)
	else
		message = color.Gold .. "You don't have enough tokens to use this perk.\n"
		tes3mp.SendMessage(pid, message, false)
		return false
	end
end

return Methods