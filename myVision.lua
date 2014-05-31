--[[
	Changelog:
	
	14530
	-Fixed issue with downloading sprites and auto-updating
	
	14531
	-Added trap support and support for OnDeleteObj()
	-Altered minimap offsets for better accuracy
	-Changed WARD_RANGE from 1450 to 1200
	-Added packet support for hidden objects
]]

--[ CONSTANTS ]--
local WARD_RANGE = 1200
local TRAP_RANGE = 300
local SPRITE_LOCATION = "myVision\\"
local AUTO_UPDATE = true
local VERSION = 14531
--[ END OF CONSTANTS ]--

if AUTO_UPDATE then
	local server_version = tonumber(GetWebResult("raw.github.com", "/Jo7j/BoL/master/version/myVision.version"))
	if server_version > VERSION then
		PrintChat("Script is outdated. Updating to version: " .. server_version .. "...")
		DownloadFile("https://raw.github.com/Jo7j/BoL/master/myVision.lua", SCRIPT_PATH .. "myVision.lua", function()
				PrintChat("Script updated. Please reload (F9).")
		end)
	end
	if server_version > VERSION then return end
end

-- Create myVision directory within Sprites folder if not already existent
if not DirectoryExist(SPRITE_PATH .. SPRITE_LOCATION) then
	CreateDirectory(SPRITE_PATH .. SPRITE_LOCATION)
end

-- Download missing sprites
local sprites = {"SummonerClairvoyance.png", "SummonerBarrier.png", "SummonerBoost.png", "SummonerDot.png", "SummonerExhaust.png", "SummonerFlash.png", "SummonerHaste.png", "SummonerHeal.png", "SummonerMana.png", "SummonerRevive.png", "SummonerSmite.png", "SummonerTeleport.png", "Minimap_Ward_Green_Enemy.png", "Minimap_Ward_Pink_Enemy.png", "minimapCP_enemyDiamond.png"}
local downloading_sprites = false
for _, sprite in pairs(sprites) do
	if not FileExist(SPRITE_PATH .. SPRITE_LOCATION .. sprite) then
		downloading_sprites = true
		DownloadFile("https://raw.github.com/Jo7j/BoL/master/Sprites/" .. sprite, SPRITE_PATH .. SPRITE_LOCATION .. sprite, function() 
			PrintChat(sprite .. " downloaded.")
		end)
	end
end
if downloading_sprites then return end

--[ GLOBALS ]--
local spellMeta = {
	{name="SummonerClairvoyance", sprite=createSprite(SPRITE_LOCATION .. "SummonerClairvoyance.png")}, 
	{name="SummonerBarrier", sprite=createSprite(SPRITE_LOCATION .. "SummonerBarrier.png")}, 
	{name="SummonerBoost", sprite=createSprite(SPRITE_LOCATION .. "SummonerBoost.png")}, 
	{name="SummonerDot", sprite=createSprite(SPRITE_LOCATION .. "SummonerDot.png")}, 
	{name="SummonerExhaust", sprite=createSprite(SPRITE_LOCATION .. "SummonerExhaust.png")}, 
	{name="SummonerFlash", sprite=createSprite(SPRITE_LOCATION .. "SummonerFlash.png")}, 
	{name="SummonerHaste", sprite=createSprite(SPRITE_LOCATION .. "SummonerHaste.png")}, 
	{name="SummonerHeal", sprite=createSprite(SPRITE_LOCATION .. "SummonerHeal.png")}, 
	{name="SummonerMana", sprite=createSprite(SPRITE_LOCATION .. "SummonerMana.png")}, 
	{name="SummonerRevive", sprite=createSprite(SPRITE_LOCATION .. "SummonerRevive.png")}, 
	{name="SummonerSmite", sprite=createSprite(SPRITE_LOCATION .. "SummonerSmite.png")}, 
	{name="SummonerTeleport", sprite=createSprite(SPRITE_LOCATION .. "SummonerTeleport.png")}, 
}
hiddenObjects = {
	sprites = {
		GreenWard = createSprite(SPRITE_LOCATION .. "Minimap_Ward_Green_Enemy.png"), 
		PinkWard = createSprite(SPRITE_LOCATION .. "Minimap_Ward_Pink_Enemy.png"), 
		Trap = createSprite(SPRITE_LOCATION .. "minimapCP_enemyDiamond.png")
	}, 
	vision = {
		{name = "Vision Ward", objectName = "VisionWard", spellName = "VisionWard", duration = math.huge, id = 8, color = ARGB(255, 255, 0, 255)}, 
		{name = "Stealth Ward", objectName = "SightWard", spellName = "SightWard", duration = 180, id = 161, color = ARGB(255, 0, 255, 0)}, 
		{name = "Warding Totem (Trinket)", objectName = "SightWard", spellName = "TrinketTotemLvl1", duration = 60, id = 56, color = ARGB(255, 0, 255, 0)}, 
		{name = "Warding Totem (Trinket)", objectName = "SightWard", spellName = "trinkettotemlvl2", duration = 120, id = 56, color = ARGB(255, 0, 255, 0)}, 
		{name = "Greater Stealth Totem (Trinket)", objectName = "SightWard", spellName = "TrinketTotemLvl3", duration = 180, id = 56, color = ARGB(255, 0, 255, 0)}, 
		{name = "Greater Vision Totem (Trinket)", objectName = "SightWard", spellName = "TrinketTotemLvl3B", duration = math.huge, id = 137, color = ARGB(255, 255, 0, 255)}, 
		{name = "Wriggle's Lantern", objectName = "SightWard", spellName = "wrigglelantern", duration = 180, id = 73, color = ARGB(255, 0, 255, 0)}, 
		{name = "Ghost Ward", objectName = "SightWard", spellName = "ItemGhostWard", duration = 180, id = 229, color = ARGB(255, 0, 255, 0)}, 
	}, 
	traps = {
		{name = "Yordle Snap Trap", objectName = "Cupcake Trap", spellName = "CaitlynYordleTrap", duration = 240, id = 62, color = ARGB(255, 255, 0, 0)}, 
		{name = "Jack In The Box", objectName = "Jack In The Box", spellName = "JackInTheBox", duration = 60, id = 2, color = ARGB(255, 255, 0, 0)}, -- Not sure about ID
		{name = "Bushwhack", objectName = "Noxious Trap", spellName = "Bushwhack", duration = 240, id = 9, color = ARGB(255, 255, 0, 0)}, -- Not sure about ID
		{name = "Noxious Trap", objectName = "Noxious Trap", spellName = "BantamTrap", duration = 600, id = 48, color = ARGB(255, 255, 0, 0)}, -- Not sure about ID
	}, 
	objects = {}
}
local spellData = {SUMMONER_1, SUMMONER_2}
local heroData = {}
local wayPointManager = WayPointManager()
--[ END OF GLOBALS ]--

function objectExist(object)
	for _, obj in pairs(hiddenObjects.objects) do
		if object.x > obj.x-32 and object.x < obj.x+32 and object.z > obj.z-32 and object.z < obj.z+32 then
			return true
		end
	end
	return false
end

function hiddenObjectByID(id)
	for _, obj in pairs(hiddenObjects.vision) do
		if id == obj.id then
			return obj
		end
	end
	for _, obj in pairs(hiddenObjects.traps) do
		if id == obj.id then
			return obj
		end
	end
	return nil
end

function getVision(viewPos, range)
	local points = {}
	local quality = 2*math.pi/25
	for theta=0, 2*math.pi+quality, quality do
		local point = D3DXVECTOR3(viewPos.x+range*math.cos(theta), viewPos.y, viewPos.z-range*math.sin(theta))
		for k=1, range, 25 do
			local pos = D3DXVECTOR3(viewPos.x+k*math.cos(theta), viewPos.y, viewPos.z-k*math.sin(theta))
			if IsWall(pos) then
				point = pos
				break
			end
		end
		points[#points+1] = point
	end
	return points
end

function drawWayPoints(object)
	local wayPoints, fTime = wayPointManager:GetSimulatedWayPoints(object)
	local points = {}
	local color = object.team == myHero.team and myVision.waypoints.allies.color or myVision.waypoints.axis.color
	for k=2, #wayPoints do
		DrawLine3D(wayPoints[k-1].x, object.y, wayPoints[k-1].y, wayPoints[k].x, object.y, wayPoints[k].y, 1, ARGB(color[1], color[2], color[3], color[4]))
		if myVision.waypoints.drawOnMinimap and not object.isMe then
			DrawLine(GetMinimapX(wayPoints[k-1].x-128), GetMinimapY(wayPoints[k-1].y+128), GetMinimapX(wayPoints[k].x-128), GetMinimapY(wayPoints[k].y+128), 1, ARGB(color[1], color[2], color[3], color[4]))
		end
		if myVision.waypoints.drawETA then
			local seconds = math.floor(fTime%60)
			DrawText3D(math.floor(fTime/60)..":".. (seconds > 9 and seconds or "0"..seconds), wayPoints[#wayPoints].x, object.y, wayPoints[#wayPoints].y, 16, ARGB(color[1], color[2], color[3], color[4]))
		end
	end
end

function GetHPBarPos(enemy)
	enemy.barData = {PercentageOffset = {x = -0.05, y = 0}}--GetEnemyBarData()
	local barPos = GetUnitHPBarPos(enemy)
	local barPosOffset = GetUnitHPBarOffset(enemy)
	local barOffset = { x = enemy.barData.PercentageOffset.x, y = enemy.barData.PercentageOffset.y }
	local barPosPercentageOffset = { x = enemy.barData.PercentageOffset.x, y = enemy.barData.PercentageOffset.y }
	local BarPosOffsetX = 171
	local BarPosOffsetY = 46
	local CorrectionY = 39
	local StartHpPos = 31

	barPos.x = math.floor(barPos.x + (barPosOffset.x - 0.5 + barPosPercentageOffset.x) * BarPosOffsetX + StartHpPos)
	barPos.y = math.floor(barPos.y + (barPosOffset.y - 0.5 + barPosPercentageOffset.y) * BarPosOffsetY + CorrectionY)

	local StartPos = Vector(barPos.x , barPos.y, 0)
	local EndPos = Vector(barPos.x + 108 , barPos.y , 0)
	return Vector(StartPos.x, StartPos.y, 0), Vector(EndPos.x, EndPos.y, 0)
end

function drawSummonerSpells(hero, id)
	local pos = GetHPBarPos(hero)
	pos.x = pos.x+128
	
	for n=1, 2 do
		if heroData[id][n].cd == nil or heroData[id][n].cd <= 0 then
			spellMeta[heroData[id][n].id].sprite:Draw(pos.x, pos.y-23+((n-1)*14), 255)
		else
			spellMeta[heroData[id][n].id].sprite:Draw(pos.x, pos.y-23+((n-1)*14), 128)
			local cx = pos.x+7
			local cy = pos.y-16+((n-1)*14)
			local angle = math.rad(-90+((heroData[id][n].maxCd-heroData[id][n].cd)/heroData[id][n].maxCd)*360)
			local x = cx + math.cos(angle) * 7
			local y = cy + math.sin(angle) * 7
			DrawLine(cx, cy, x, y, 1, ARGB(255, 255, 255, 255))
		end
	end
end
--[ END OF FUNCTIONS ]--

--[ CALLBACKS ]--
function OnLoad()
	myVision = scriptConfig("myVision", "myVision")
	
	myVision:addSubMenu("Waypoints", "waypoints")
	myVision.waypoints:addParam("drawOnMinimap", "Draw On Minimap", SCRIPT_PARAM_ONOFF, true)
	myVision.waypoints:addParam("drawETA", "Draw ETA", SCRIPT_PARAM_ONOFF, true)
	
	myVision.waypoints:addSubMenu("Allies", "allies")
	myVision.waypoints.allies:addParam("enabled", "Enabled", SCRIPT_PARAM_ONOFF, true)
	myVision.waypoints.allies:addParam("color", "Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 0})
	
	myVision.waypoints:addSubMenu("Enemies", "axis")
	myVision.waypoints.axis:addParam("enabled", "Enabled", SCRIPT_PARAM_ONOFF, true)
	myVision.waypoints.axis:addParam("color", "Color", SCRIPT_PARAM_COLOR, {255, 255, 0, 0})
	
	
	myVision:addSubMenu("Hidden Objects", "hiddenObjects")
	myVision.hiddenObjects:addParam("drawOnMinimap", "Draw On Minimap", SCRIPT_PARAM_ONOFF, true)
	myVision.hiddenObjects:addParam("drawCreator", "Draw Creator", SCRIPT_PARAM_ONOFF, true)
	myVision.hiddenObjects:addParam("useCircles", "Use Circles", SCRIPT_PARAM_ONOFF, false)
	
	
	myVision:addSubMenu("Hero Tracker", "heroTracker")
	myVision.heroTracker:addParam("drawSpells", "Draw Summoner Spells", SCRIPT_PARAM_ONOFF, true)
	--myVision.heroTracker:addParam("drawAbilites", "Draw Abilities", SCRIPT_PARAM_ONOFF, true)
	
	
	--myVision:addSubMenu("Jungle Timers", "jungleTimers")
	
	for i=1, heroManager.iCount, 1 do
		local hero = heroManager:getHero(i)
		
		heroData[i] = {}
		for n=1, 2 do
			heroData[i][n] = {id=nil, cd=0, maxCd=0}

			for k, spell in ipairs(spellMeta) do
				local tmpSpell = hero:GetSpellData(spellData[n]).name
				if tmpSpell:find(spell.name) then
					heroData[i][n].id = k
				end
			end
		end
	end
	
	PrintChat("myVision rev. " .. VERSION)
end

function OnRecvPacket(p)
	if p.header == 180 then -- Create
		p.pos = 1
		local creator = objManager:GetObjectByNetworkId(p:DecodeF())
		if creator.team ~= myHero.team then
			p.pos = 13
			local id = p:Decode1()
			p.pos = 37
			local networkID = p:DecodeF()
			p.pos = 53
			local object = {x = p:DecodeF(), y = p:DecodeF(), z = p:DecodeF()}
			local obj = hiddenObjectByID(id)
			if obj and not objectExist(object) then
				table.insert(hiddenObjects.objects, {x=object.x, y=object.y, z=object.z, endTime=GetGameTimer()+obj.duration, data=obj, creator=creator.charName, points=getVision(object, WARD_RANGE), networkID=DwordToFloat(AddNum(FloatToDword(networkID), 2))})
			end
		end
	elseif p.header == 49 then -- Delete
		p.pos = 1
		local networkID = p:DecodeF()
		for i, obj in pairs(hiddenObjects.objects) do
			if obj.networkID and obj.networkID == networkID then
				table.remove(hiddenObjects.objects, i)
			end
		end
	end
end

function OnProcessSpell(object, spellProc)
	if object.type == "obj_AI_Hero" and object.team ~= myHero.team then
		for _, obj in pairs(hiddenObjects.vision) do
			if spellProc.name == obj.spellName and not objectExist(spellProc.endPos) then
				table.insert(hiddenObjects.objects, {x=spellProc.endPos.x, y=spellProc.endPos.y, z=spellProc.endPos.z, endTime=GetGameTimer()+obj.duration, data=obj, creator=object.charName, points=getVision(spellProc.endPos, WARD_RANGE)})
				break
			end
		end
		for _, obj in pairs(hiddenObjects.traps) do
			if spellProc.name == obj.spellName and not objectExist(spellProc.endPos) then
				table.insert(hiddenObjects.objects, {x=spellProc.endPos.x, y=spellProc.endPos.y, z=spellProc.endPos.z, endTime=GetGameTimer()+obj.duration, data=obj, creator=object.charName, points=getVision(spellProc.endPos, TRAP_RANGE)})
				break
			end
		end
	end
end

function OnDeleteObj(object)
	for i, obj in pairs(hiddenObjects.objects) do
		if object.name == obj.data.objectName and object.x < obj.x+100 and object.x > obj.x-100 and object.z < obj.z+100 and object.z > obj.z-100 then
			table.remove(hiddenObjects.objects, i)
		end
	end
end

function OnDraw()
	for i=1, heroManager.iCount do
		local hero = heroManager:getHero(i)
		
		-- Log current cooldowns
		for n=1, 2 do -- This should probably go in OnTick()
			heroData[i][n].cd = math.floor(hero:GetSpellData(spellData[n]).currentCd)
			heroData[i][n].maxCd = heroData[i][n].cd > heroData[i][n].maxCd and heroData[i][n].cd or heroData[i][n].maxCd
		end
		
		-- Draw Summoner Spells
		if myVision.heroTracker.drawSpells and hero.visible and not hero.dead then
				drawSummonerSpells(hero, i)
		end
		
		-- Draw WayPoints
		if (myVision.waypoints.allies.enabled and hero.team == myHero.team) or (myVision.waypoints.axis.enabled and hero.team ~= myHero.team) then
			drawWayPoints(hero)
		end
	end
	
	-- Draw Hidden Objects
	for i, obj in pairs(hiddenObjects.objects) do
		if GetGameTimer() > obj.endTime then
			table.remove(hiddenObjects.objects, i)
		end
		
		-- Draw on map
		if myVision.hiddenObjects.drawOnMinimap then
			if obj.data.objectName:find("Sight") then
				hiddenObjects.sprites.GreenWard:Draw(GetMinimapX(obj.x-128), GetMinimapY(obj.z+128), 255)
			elseif obj.data.objectName:find("Vision") then
				hiddenObjects.sprites.PinkWard:Draw(GetMinimapX(obj.x-128), GetMinimapY(obj.z+128), 255)
			else
				hiddenObjects.sprites.Trap:Draw(GetMinimapX(obj.x-128), GetMinimapY(obj.z+128), 255)
			end
		end
		
		DrawCircle(obj.x, obj.y, obj.z, 100, obj.data.color)
		
		--Draw vision
		if obj.data.objectName:find("Ward") then
			if myVision.hiddenObjects.useCircles then
				DrawCircle(obj.x, obj.y, obj.z, WARD_RANGE, obj.data.color)
			else
				for k=2, #obj.points do
					DrawLine3D(obj.points[k-1].x, obj.y, obj.points[k-1].z, obj.points[k].x, obj.y, obj.points[k].z, 1, obj.data.color)
				end
			end
		end

		local t = obj.endTime-GetGameTimer()
		if t ~= math.huge then
			local m = math.floor(t/60)
			local s = math.ceil(t%60)
			s = (s<10 and "0"..s) or s
			DrawText3D(m..":"..s, obj.x, obj.y, obj.z, 16, ARGB(255, 255, 255, 255), true)
		end
		if obj.creator ~= nil and myVision.hiddenObjects.drawCreator then
			DrawText3D("\n"..obj.creator, obj.x, obj.y, obj.z, 16, ARGB(255, 255, 255, 255), true)
		else
			DrawText3D("\n?", obj.x, obj.y, obj.z, 16, ARGB(255, 255, 255, 255), true)
		end
	end
end

function OnUnload()
	for i, spell in pairs(spellMeta) do
		if spellMeta[i].sprite ~= nil then
			spellMeta[i].sprite:Release()
		end
	end
	if hiddenObjects.sprites.GreenWard ~= nil then
		hiddenObjects.sprites.GreenWard:Release()
	end
	if hiddenObjects.sprites.PinkWard ~= nil then
		hiddenObjects.sprites.PinkWard:Release()
	end
	if hiddenObjects.sprites.Trap ~= nil then
		hiddenObjects.sprites.Trap:Release()
	end
end
--[ END OF CALLBACKS ]--
