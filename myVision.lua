--[[
		         __   ___    _
		 _ __ _  \ \ / (_)__(_)___ _ _
		| '  \ || \ V /| (_-< / _ \ ' \
		|_|_|_\_, |\_/ |_/__/_\___/_||_|
		      |__/  by Jorj

		The simple, lightweight and 
			open-source awareness script
]]

local REVISION = 13

local allyHeroes, enemyHeroes = GetAllyHeroes(), GetEnemyHeroes()
local rad, sin, cos = math.rad, math.sin, math.cos

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

local spellData = { }

for i = 1, heroManager.iCount do
	local hero = heroManager:getHero(i)

	if hero and hero.valid then
		spellData[hero.index] = {
			[_Q] = hero:GetSpellData(_Q), 
			[_W] = hero:GetSpellData(_W), 
			[_E] = hero:GetSpellData(_E), 
			[_R] = hero:GetSpellData(_R), 
			[SUMMONER_1] = hero:GetSpellData(SUMMONER_1), 
			[SUMMONER_2] = hero:GetSpellData(SUMMONER_2), 
		}
	end
end

function OnLoad()
	local latest = tonumber(GetWebResult("raw.github.com", "/Jo7j/BoL/master/myVision.rev"))

	if latest > REVISION then
		Print("A new update is available. Please update using the menu.")
	end

	Config = scriptConfig("myVision (rev. " .. REVISION .. ")", "myVision")
		Config:addSubMenu("Ally Settings", "ally")
			Config.ally:addParam("active", "Enabled", SCRIPT_PARAM_ONOFF, false)

		Config:addSubMenu("Enemy Settings", "enemy")
			Config.enemy:addParam("active", "Enabled", SCRIPT_PARAM_ONOFF, true)

		Config:addParam("updateScript", "Update Script (rev. " .. latest .. ")", SCRIPT_PARAM_ONOFF, false)
		Config.updateScript = false

	Print("<font color=\"#77FF77\">Loaded</font>")
end

function OnUnload()
	if abilityFrame then
		abilityFrame:Release()
	end

	for spellName, sprite in pairs(summonerSprites) do
		if sprite then
			sprite:Release()
		end
	end
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
	for _, ally in pairs(allyHeroes) do
		if Config.ally.active and ally.visible and ally.bTargetable and not ally.dead then
			local framePos = GetAbilityFramePos(ally)
				
			if OnScreen(framePos, framePos) then
				DrawOverheadHUD(ally, framePos)
			end
		end
	end

	for _, enemy in pairs(enemyHeroes) do
		if Config.enemy.active and enemy.visible and enemy.bTargetable and not enemy.dead then
			local framePos = GetAbilityFramePos(enemy)
				
			if OnScreen(framePos, framePos) then
				DrawOverheadHUD(enemy, framePos)
			end
		end
	end
end

function DrawOverheadHUD(unit, framePos)
	if abilityFrame then
		abilityFrame:Draw(framePos.x, framePos.y, 255)
	else
		DrawRectangle(framePos.x, framePos.y - 1, 110, 9, 0xFF000000)
		DrawRectangleOutline(framePos.x, framePos.y - 1, 110, 9, 0xFF737173, 1)
		DrawRectangleOutline(framePos.x + 1, framePos.y, 108, 7, 0xFF4A494A, 1)
	end

	for spellID = _Q, _R do
		local pSpellData = spellData[unit.index][spellID]

		if pSpellData.level > 0 then
			local framePos = Point(framePos.x + 3, framePos.y + 3)
			local spellPos = Point(framePos.x + (spellID * 26), framePos.y)

			if pSpellData.isToggleSpell and pSpellData.toggleState > 0 then
				DrawLine(spellPos.x, spellPos.y, spellPos.x + 25, spellPos.y, 3, pSpellData.toggleState == 2 and 0xFF32CD32 or 0xFF2E8B57)
			elseif pSpellData.currentCd <= 0 then
				DrawLine(spellPos.x, spellPos.y, spellPos.x + 25, spellPos.y, 3, 0xFF32CD32)
			else
				DrawLine(spellPos.x, spellPos.y, spellPos.x + 25, spellPos.y, 3, 0xFF800000)
				if pSpellData.totalCooldown > 0 then
					DrawLine(spellPos.x, spellPos.y, spellPos.x + (pSpellData.totalCooldown - pSpellData.currentCd) / pSpellData.totalCooldown * 25, spellPos.y, 3, 0xFF2E8B57)
				end
				local strCooldown = tostring(pSpellData.currentCd < 10 and math.round(pSpellData.currentCd, 1) or math.ceil(pSpellData.currentCd))
				DrawText(strCooldown, 14, spellPos.x - GetTextArea(strCooldown, 14).x / 2 + 12.5, spellPos.y + 5, 0xFFFFFFFF)
			end

			DrawLine(spellPos.x, spellPos.y + 1, spellPos.x + 25, spellPos.y + 1, 1, 0x3F000000)
		end
	end

	local barPos = Point(framePos.x - 13, framePos.y - 18)
					
	for spellID = SUMMONER_1, SUMMONER_2 do
		local pSpellData = spellData[unit.index][spellID]
		local pSprite = summonerSprites[pSpellData.name]
		local midPos = Point(barPos.x + 6, barPos.y + (spellID - SUMMONER_1) * 13 + 6)

		if pSpellData.currentCd > 0 then
			local angle = rad(-90 + (pSpellData.totalCooldown - pSpellData.currentCd) / pSpellData.totalCooldown * 360)

			if pSprite then
				pSprite:Draw(barPos.x, barPos.y + (spellID - SUMMONER_1) * 13, 128)
			end
			DrawLine(midPos.x, midPos.y, midPos.x + cos(angle) * 6, midPos.y + sin(angle) * 6, 1, 0xFFFFFFFF)
		elseif pSprite then
			pSprite:Draw(barPos.x, barPos.y + (spellID - SUMMONER_1) * 13, 255)
		end
	end
end

--[[
	Utility functions

	Print(value) - Prints value to chat.
	GetAbilityFramePos(unit) - Returns the top-left corner of where the ability frame should be positioned.
]]

function Print(value)
	PrintChat("<font color=\"#AAAAAA\"><b>myVision (rev. " .. REVISION .. ")</b>: </font><font color=\"#FFFFFF\">" .. value .. "</font>")
end

function GetAbilityFramePos(unit)
	local barPos = GetUnitHPBarPos(unit)
	local barOffset = GetUnitHPBarOffset(unit)

	do -- For some reason the x offset never exists
		local t = {
			["Renekton"] = -0.05
		}
		barOffset.x = t[unit.charName] or 0
	end

	return Point(barPos.x - 69 + barOffset.x * 150, barPos.y + barOffset.y * 52.5 + 12.5)
end

-- ScriptStatus Lua Plugin
assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("REHGEHHMJKD") 
