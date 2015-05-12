--[[
		         __   ___    _
		 _ __ _  \ \ / (_)__(_)___ _ _
		| '  \ || \ V /| (_-< / _ \ ' \
		|_|_|_\_, |\_/ |_/__/_\___/_||_|
		      |__/  by Jorj

		The simple, lightweight and 
			open-source awareness script
]]

local revision = 11

local abilityFrame = FileExist(SPRITE_PATH .. "myVision\\abilityFrame.png") and createSprite("myVision\\abilityFrame.png")
local summonerSprites = { }

function OnLoad()
	-- Get latest revision
	local latest = tonumber(GetWebResult("raw.github.com", "/Jo7j/BoL/master/myVision.rev"))
	if latest > revision then
		Print("A new update is available. Please update using the menu.")
	end

	Config = scriptConfig("myVision (rev. " .. revision .. ")", "myVision")
		Config:addSubMenu("Ally Settings", "ally")
			Config.ally:addParam("active", "Enabled", SCRIPT_PARAM_ONOFF, false)
			Config.ally:addParam("self", "Local Hero", SCRIPT_PARAM_ONOFF, false)

		Config:addSubMenu("Enemy Settings", "enemy")
			Config.enemy:addParam("active", "Enabled", SCRIPT_PARAM_ONOFF, true)

		Config:addParam("updateScript", "Update Script (rev. " .. latest .. ")", SCRIPT_PARAM_ONOFF, false)
		Config.updateScript = false -- Prevent scriptConfig from reading saved value

	-- Load the sprites
	for _, spellName in pairs({"itemsmiteaoe", "s5_summonersmiteduel", "s5_summonersmiteplayerganker", "s5_summonersmitequick", 
		"snowballfollowupcast", "summonerbarrier", "summonerboost", "summonerclairvoyance", "summonerdot", 
		"summonerexhaust", "summonerflash", "summonerhaste", "summonerheal", "summonermana", 
		"summonerodingarrison", "summonerpororecall", "summonerporothrow", "summonerrevive", "summonersmite", 
		"summonersnowball", "summonerteleport"}) do
		local location = "myVision\\spells\\" .. spellName .. ".png"

		if FileExist(SPRITE_PATH .. location) then
			summonerSprites[spellName] = createSprite(location)
		else
			Print(location .. " not found.")
		end
	end

	summonerSprites["teleportcancel"] = summonerSprites["summonerteleport"]

	Print("<font color=\"#77FF77\">Loaded</font>")
end

function OnWndMsg(a, b)
	if a == WM_LBUTTONUP and Config.updateScript then
		Config.updateScript = false
		Print("Updating...")
		DownloadFile("https://raw.githubusercontent.com/Jo7j/BoL/master/myVision.lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, function()
 			Print("Update finished Please reload (F9).")
		end)
	end
end

function OnDraw()
	for i = 1, heroManager.iCount do
		local hero = heroManager:getHero(i)

		if hero and hero.visible and not hero.dead and hero.bTargetable and ((hero.isMe and Config.ally.self) or (hero.team == TEAM_ENEMY and Config.enemy.active) or (Config.ally.active and not hero.isMe)) then
			local screenPos = WorldToScreen(D3DXVECTOR3(hero.x, hero.y, hero.z))
				
			if OnScreen(screenPos, screenPos) then
				-- Draw the hero's abilities
				local framePos = GetAbilityFramePos(hero)

				-- Draw the ability frame
				if abilityFrame then
					abilityFrame:Draw(framePos.x, framePos.y, 255)
				end

				for spellID = _Q, _R do
					local spellData = hero:GetSpellData(spellID)

					if spellData.level > 0 then
						local spellPos = Point(framePos.x + 3 + (spellID * 26), framePos.y + 3)

						if spellData.currentCd < 1 and spellData.toggleState == 0 then -- Ability is off cooldown
							DrawLine(spellPos.x, spellPos.y, spellPos.x + 25, spellPos.y, 3, ARGB(255, 50, 205, 50))
						elseif spellData.toggleState > 0 then
							DrawLine(spellPos.x, spellPos.y, spellPos.x + 25, spellPos.y, 3, spellData.toggleState == 2 and ARGB(255, 50, 205, 50) or ARGB(255, 46, 139, 87))
						else
							DrawLine(spellPos.x, spellPos.y, spellPos.x + 25, spellPos.y, 3, ARGB(255, 128, 0, 0))

							DrawLine(spellPos.x, spellPos.y, spellPos.x + (spellData.totalCooldown - spellData.currentCd) / spellData.totalCooldown * 25, spellPos.y, 3, ARGB(255, 46, 139, 87))

							local strCooldown = tostring(round(spellData.currentCd))
							DrawText(strCooldown, 14, spellPos.x - GetTextArea(strCooldown, 14).x / 2 + 12.5, spellPos.y + 5, ARGB(255, 255, 255, 255))
						end
					end
				end

				-- Draw the hero's summoner spells
				local barPos = hero.isMe and Point(framePos.x + 110, framePos.y - 16) or Point(framePos.x - 13, framePos.y - 16)
					
				for spellID = SUMMONER_1, SUMMONER_2 do
					local spellData = hero:GetSpellData(spellID)
					local midPos = Point(barPos.x + 6, barPos.y + (spellID - SUMMONER_1) * 13 + 6)

					if spellData.currentCd > 0 then
						local angle = math.rad(-90 + (spellData.totalCooldown - spellData.currentCd) / spellData.totalCooldown * 360)

						if summonerSprites[spellData.name] then
							summonerSprites[spellData.name]:Draw(barPos.x, barPos.y + (spellID - SUMMONER_1) * 13, 128)
						end
						--DrawLine(midPos.x, midPos.y, midPos.x + math.cos(angle - 0.1) * 6, midPos.y + math.sin(angle - 0.1) * 6, 1, ARGB(255, 0, 0, 0)) -- Shadow
						DrawLine(midPos.x, midPos.y, midPos.x + math.cos(angle) * 6, midPos.y + math.sin(angle) * 6, 1, ARGB(255, 255, 255, 255))
					elseif summonerSprites[spellData.name] then
						summonerSprites[spellData.name]:Draw(barPos.x, barPos.y + (spellID - SUMMONER_1) * 13, 255)
					end
				end
			end
		end
	end
end

--[[
	Utility functions

	Print(value) - Prints value to chat.
	round(float) - Returns the rounded number from float.
	GetAbilityFramePos(unit) - Returns the top-left corner of where the ability frame should be positioned.
]]

function Print(value)
	PrintChat("<font color=\"#AAAAAA\"><b>myVision (rev. " .. revision .. ")</b>: </font><font color=\"#FFFFFF\">" .. value .. "</font>")
end

function round(a)
	local b = math.floor(a)
	if a >= b + 0.5 then
		return math.ceil(a)
	else
		return math.floor(a)
	end
end

function GetAbilityFramePos(unit)
	if unit.isMe then
		local barPos = GetUnitHPBarPos(unit)
		local barOffset = GetUnitHPBarOffset(unit)
		return Point(barPos.x - 45, barPos.y + barOffset.y * 50 + 9)
	else
		local barPos = GetUnitHPBarPos(unit)
		local barOffset = GetUnitHPBarOffset(unit)
		return Point(barPos.x - 69, barPos.y + barOffset.y * 50 + 12)
	end
end

-- ScriptStatus Lua Plugin
assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("REHGEHHMJKD") 
