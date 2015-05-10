--[[
		         __   ___    _
		 _ __ _  \ \ / (_)__(_)___ _ _
		| '  \ || \ V /| (_-< / _ \ ' \
		|_|_|_\_, |\_/ |_/__/_\___/_||_|
		      |__/  by Jorj

		The simple, lightweight and 
			open-source awareness script
]]

local revision = 10

function OnLoad()
	-- Get latest revision
	local latest = tonumber(GetWebResult("raw.github.com", "/Jo7j/BoL/master/myVision.rev"))
	if latest > revision then
		Print("A new update is available. Please update using the menu.")
	end

	Config = scriptConfig("myVision (rev. " .. revision .. ")", "myVision")
		Config:addParam("updateScript", "Update Script (rev. " .. latest .. ")", SCRIPT_PARAM_ONOFF, false)
		Config.updateScript = false -- Prevent scriptConfig from reading saved value

	LoadOverheadHUD()

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

function LoadOverheadHUD()
	-- Load the sprites
	local abilityFrame = FileExist(SPRITE_PATH .. "myVision\\abilityFrame.png") and createSprite("myVision\\abilityFrame.png")
	local summonerSprites = { }

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

	local function OnDraw()
		for _, enemy in pairs(GetEnemyHeroes()) do
			if enemy and enemy.visible and not enemy.dead and enemy.bTargetable then
				local screenPos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
				
				if OnScreen(screenPos, screenPos) then
					-- Draw the enemy's abilities
					local framePos = GetAbilityFramePos(enemy)

					-- Draw the ability frame
					if abilityFrame then
						abilityFrame:Draw(framePos.x, framePos.y, 255)
					end

					for spellID = _Q, _R do
						local spellData = enemy:GetSpellData(spellID)

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

					-- Draw the enemy's summoner spells
					local barPos = Point(framePos.x - 13, framePos.y - 16)
					
					for spellID = SUMMONER_1, SUMMONER_2 do
						local spellData = enemy:GetSpellData(spellID)
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

	AddDrawCallback(OnDraw)
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
	local barPos = GetUnitHPBarPos(unit)
	local barOffset = GetUnitHPBarOffset(unit)
	return Point(barPos.x - 69, barPos.y + barOffset.y * 50 + 12)
end
