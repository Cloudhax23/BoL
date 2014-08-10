local mapIndex = GetGame().map.index

function OnLoad()
	_G.enemyHeroes = GetEnemyHeroes()

	Config = scriptConfig("myVision", "myVision")
	
	Config:addSubMenu("Way Points", "wayPoints")
		Config.wayPoints:addParam("drawWorld", "Draw 3D", SCRIPT_PARAM_ONOFF, true)
		Config.wayPoints:addParam("drawMinimap", "Draw 2D", SCRIPT_PARAM_ONOFF, true)
		Config.wayPoints:addParam("drawETA", "Draw ETA", SCRIPT_PARAM_ONOFF, true)
	
	Config.wayPoints:addSubMenu("Allies", "allies")
		Config.wayPoints.allies:addParam("enabled", "Enabled", SCRIPT_PARAM_ONOFF, true)
		Config.wayPoints.allies:addParam("color", "Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 255})
		Config.wayPoints.allies:addParam(myHero.charName, myHero.charName, SCRIPT_PARAM_ONOFF, true)
		for _, ally in pairs(GetAllyHeroes()) do
			Config.wayPoints.allies:addParam(ally.charName, ally.charName, SCRIPT_PARAM_ONOFF, true)
		end
	
	Config.wayPoints:addSubMenu("Enemies", "axis")
		Config.wayPoints.axis:addParam("enabled", "Enabled", SCRIPT_PARAM_ONOFF, true)
		Config.wayPoints.axis:addParam("color", "Color", SCRIPT_PARAM_COLOR, {255, 255, 0, 0})
		for _, enemy in pairs(enemyHeroes) do
			Config.wayPoints.axis:addParam(enemy.charName, enemy.charName, SCRIPT_PARAM_ONOFF, true)
		end
	
	if mapIndex == 1 then
		Config:addSubMenu("Hidden Objects", "hiddenObjects")
			Config.hiddenObjects:addParam("drawAlly", "Draw ally wards", SCRIPT_PARAM_ONOFF, true)
			Config.hiddenObjects:addParam("drawAxis", "Draw enemy wards", SCRIPT_PARAM_ONOFF, true)
			Config.hiddenObjects:addParam("drawMinimap", "Draw on minimap", SCRIPT_PARAM_ONOFF, true)
			Config.hiddenObjects:addParam("useLFC", "Use lag-free circles", SCRIPT_PARAM_ONOFF, true)
	end
	
	Config:addSubMenu("Minimap Timers", "minimapTimers")
		Config.minimapTimers:addParam("hotkey", "Clear camp hotkey" , SCRIPT_PARAM_ONKEYDOWN, false, GetKey('K'))
		Config.minimapTimers:addParam("textSize", "Minimap text size", SCRIPT_PARAM_SLICE, 14, 10, 20, 0)
		Config.minimapTimers:addParam("textColor", "Minimap text color", SCRIPT_PARAM_COLOR, {255, 255, 255, 255})
		Config.minimapTimers:addParam("sendChatKey", "Send to chat on click hotkey", SCRIPT_PARAM_ONKEYDOWN, false, 0x10)
		
	Config:addSubMenu("Minion EXP range", "expRange")
		Config.expRange:addParam("enabled", "Enabled", SCRIPT_PARAM_ONOFF, true)
		Config.expRange:addParam("drawType", "Draw type", SCRIPT_PARAM_LIST, 1, {"Circle", "Line"})
		Config.expRange:addParam("maxOpacity", "Max opacity", SCRIPT_PARAM_SLICE, 128, 32, 255, 0)
		Config.expRange:addParam("color", "Color", SCRIPT_PARAM_COLOR, {255, 255, 255, 255})
		Config.expRange:addParam("lineLength", "Line length", SCRIPT_PARAM_SLICE, 300, 10, 500, 0)
		Config.expRange:addParam("useLFC", "Lag-free circles", SCRIPT_PARAM_ONOFF, true)
	
	Config:addSubMenu("Overhead HUD", "overheadHUD")
		Config.overheadHUD:addParam("drawAbilities", "Draw abilities", SCRIPT_PARAM_ONOFF, true)
		Config.overheadHUD:addParam("drawSummoners", "Draw summoner spells", SCRIPT_PARAM_ONOFF, true)
		Config.overheadHUD:addParam("showDetails", "Show details", SCRIPT_PARAM_ONKEYDOWN, false, 0x10)
	
	Config:addSubMenu("Recall Tracker", "recallTracker")
		Config.recallTracker:addParam("drawMinimap", "Draw circle on minimap", SCRIPT_PARAM_ONOFF, true)
		Config.recallTracker:addParam("maxSize", "Maximum circle size", SCRIPT_PARAM_SLICE, 5000, 1000, 10000, 0)
	
	local oPrintChat = PrintChat
	PrintChat = function(input)
		oPrintChat("<font color=\"#AAAAAA\"><b>myVision</b>: </font><font color=\"#FFFFFF\">" .. input .. "</font>")
	end
	PrintError = function(input)
		oPrintChat("<font color=\"#AAAAAA\"><b>myVision</b>: </font><font color=\"#FF7777\">" .. input .. "</font>")
	end
	
	wayPoints()
	minimapTimers()
	if mapIndex == 1 then
		hiddenObjects()
	end
	if mapIndex ~= 12 then
		recallTracker()
	end
	expRangeIndicator()
	connectionStatus()
	overheadHUD()
	
	PrintChat("<font color=\"#77FF77\">Loaded</font>")
end

function round(float)
	local down = math.floor(float)
	if float >= down + 0.5 then -- round up
		return math.ceil(float)
	else -- round down
		return math.floor(float)
	end
end

function DrawLFC(x, y, z, radius, color, quality)
	local screenMin = WorldToScreen(D3DXVECTOR3(x - radius, y, z + radius))

	if OnScreen({x = screenMin.x, y = screenMin.y}, {x = screenMin.x, y = screenMin.y}) then
		local quality = quality and 2 * math.pi / quality or 2 * math.pi / math.floor(radius / 10)
		local a = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(0), y, z - radius * math.sin(0)))
		
		for theta = quality, 2 * math.pi + quality, quality do
			local b = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
			DrawLine(a.x, a.y, b.x, b.y, 1, color)
			a = b
		end
	end
end

function GetHPBarPos(unit)
	local barPos = GetUnitHPBarPos(unit)
	local barOffset = GetUnitHPBarOffset(unit)
	if unit.charName == "Darius" then
		barPos.x = barPos.x - 8
	elseif unit.charName == "JarvanIV" then
		barPos.x = barPos.x - 14
	end
	return Point(barPos.x - 69, barPos.y + (barOffset.y * 50) - 6 - (unit.isMe and 6 or 0))
end

class "wayPoints"

function wayPoints:__init()
	self.wayPointManager = WayPointManager()

	AddDrawCallback(function() self:OnDraw() end)
end

function wayPoints:OnDraw()
	for i=1, heroManager.iCount do
		local hero = heroManager:getHero(i)
		if (Config.wayPoints.allies.enabled and hero.team ~= TEAM_ENEMY and Config.wayPoints.allies[hero.charName]) or (Config.wayPoints.axis.enabled and hero.team == TEAM_ENEMY and Config.wayPoints.axis[hero.charName]) then
			local wayPoints, fTime = self.wayPointManager:GetSimulatedWayPoints(hero)
			if GetDistance(hero, wayPoints[#wayPoints]) > hero.boundingRadius then
				local points = {}
				local color = hero.team == TEAM_ENEMY and Config.wayPoints.axis.color or Config.wayPoints.allies.color
				
				for k=2, #wayPoints do
					if Config.wayPoints.drawWorld then
						DrawLine3D(wayPoints[k-1].x, hero.y, wayPoints[k-1].y, wayPoints[k].x, hero.y, wayPoints[k].y, 1, ARGB(color[1], color[2], color[3], color[4]))
					end
					
					if Config.wayPoints.drawMinimap and not hero.isMe then
						DrawLine(GetMinimapX(wayPoints[k-1].x-128), GetMinimapY(wayPoints[k-1].y+128), GetMinimapX(wayPoints[k].x-128), GetMinimapY(wayPoints[k].y+128), 1, ARGB(color[1], color[2], color[3], color[4]))
					end
				end
				
				if Config.wayPoints.drawETA then
					local seconds = math.round(fTime%60)
					DrawText3D(math.floor(fTime/60)..":".. (seconds > 9 and seconds or "0"..seconds), wayPoints[#wayPoints].x, hero.y, wayPoints[#wayPoints].y, 16, ARGB(color[1], color[2], color[3], color[4]))
				end
			end
		end
	end
end

class "hiddenObjects"

function hiddenObjects:__init()
	self.hiddenObjects = {
		meta = {
			{duration = 25000, id = 6424612, name = "VisionWard", charName = "VisionWard", color = ARGB(255, 255, 0, 255), type = "pink"}, -- Vision Ward
			{duration = 180, id = 234594676, name = "SightWard", charName = "SightWard", color = ARGB(255, 0, 255, 0), type = "green"}, -- Stealth Ward
			{duration = 60, id = 263796881, name = "SightWard", charName = "YellowTrinket", color = ARGB(255, 0, 255, 0), type = "green"}, -- Warding Totem (Trinket)
			{duration = 120, id = 263796882, name = "SightWard", charName = "YellowTrinketUpgrade", color = ARGB(255, 0, 255, 0), type = "green"}, -- Warding Totem (Trinket) (Lvl.9)
			{duration = 180, id = 263796882, name = "SightWard", charName = "SightWard", color = ARGB(255, 0, 255, 0), type = "green"}, -- Greater Stealth Totem (Trinket)
			{duration = 25000, id = 194218338, name = "VisionWard", charName = "VisionWard", color = ARGB(255, 255, 0, 255), type = "pink"}, -- Greater Vision Totem (Trinket)
			{duration = 180, id = 177751558, name = "SightWard", charName = "SightWard", color = ARGB(255, 0, 255, 0), type = "green"}, -- Wriggle's Lantern
			{duration = 180, id = 135609454, name = "SightWard", charName = "SightWard", color = ARGB(255, 0, 255, 0), type = "green"}, -- Quill Coat
			{duration = 180, id = 101180708, name = "VisionWard", charName = "SightWard", color = ARGB(255, 0, 255, 0), type = "green"}, -- Ghost Ward
		}, 
		sprites = {
			GreenWard = FileExist(SPRITE_PATH .. "myVision\\minimap\\Minimap_Ward_Green_Enemy.tga") and createSprite("myVision\\minimap\\Minimap_Ward_Green_Enemy.tga"), 
			PinkWard = FileExist(SPRITE_PATH .. "myVision\\minimap\\Minimap_Ward_Pink_Enemy.tga") and createSprite("myVision\\minimap\\Minimap_Ward_Pink_Enemy.tga"), 
		}, 
		objects = {}
	}
	
	AddRecvPacketCallback(function(p) self:OnRecvPacket(p) end)
	AddDeleteObjCallback(function(object) self:OnDeleteObj(object) end)
	AddDrawCallback(function() self:OnDraw() end)
	
	if self.hiddenObjects.sprites.GreenWard then
		AddUnloadCallback(function()
			if self.hiddenObjects.sprites.GreenWard then
				self.hiddenObjects.sprites.GreenWard:Release()
			end
		end)
	end
	if self.hiddenObjects.sprites.PinkWard then
		AddUnloadCallback(function()
			if self.hiddenObjects.sprites.PinkWard then
				self.hiddenObjects.sprites.PinkWard:Release()
			end
		end)
	end
end

function hiddenObjects:OnRecvPacket(p)
	if p.header == 0xB5 then
		p.pos = 1
		local caster = objManager:GetObjectByNetworkId(p:DecodeF())
		if caster then
			p.pos = 12
			local id = p:Decode4()
			p.pos = 37
			local projectileId = p:Decode4()
			p.pos = 53
			local endPos = Vector(p:DecodeF(), p:DecodeF(), p:DecodeF())

			for _, meta in pairs(self.hiddenObjects.meta) do
				if id == meta.id then
					return table.insert(self.hiddenObjects.objects, {startT = GetInGameTimer(), pos = endPos, networkID = DwordToFloat(AddNum(projectileId, 2)), creator = caster, meta = meta})
				end
			end
		end
	elseif p.header == 0x07 then
		p.pos = 1
		local objectNetworkId = p:DecodeF()
		local creatorNetworkId = p:DecodeF()
		
		DelayAction(function()
			local object = objManager:GetObjectByNetworkId(objectNetworkId)
			local creator = objManager:GetObjectByNetworkId(creatorNetworkId)
			
			if object then
				local pos = Vector(object.x, object.y, object.z)
				
				for i, obj in pairs(self.hiddenObjects.objects) do -- Check if the object already exists
					if obj.networkID == object.networkID then
						obj.pos = pos -- Update the objects position
						return
					end
				end
				
				for _, meta in pairs(self.hiddenObjects.meta) do -- Find the object's meta data
					if meta.name == object.name and meta.charName == object.charName then
						return table.insert(self.hiddenObjects.objects, {startT = GetInGameTimer(), pos = pos, networkID = object.networkID, creator = creator, meta = meta})
					end
				end
			else
				PrintChat(creator.charName .. " has planted a ward")
			end
		end, 2.5)
	elseif p.header == 0x32 then
		p.pos = 1
		local networkID = p:DecodeF()
		for i, obj in ipairs(self.hiddenObjects.objects) do
			if obj.networkID and obj.networkID == networkID then
				table.remove(self.hiddenObjects.objects, i)
				break
			end
		end
	end
end

function hiddenObjects:OnDeleteObj(object)
	if object and object.valid and object.name:find("Ward") then
		for i, obj in ipairs(self.hiddenObjects.objects) do
			if object.networkID == obj.networkID or GetDistance(object, obj.pos) < 1 then -- Usually the object is deleted before we can get the networkID
				table.remove(self.hiddenObjects.objects, i)
				return
			end
		end
	end
end

function hiddenObjects:OnDraw()
	for i, obj in pairs(self.hiddenObjects.objects) do
		if obj.creator == nil or (obj.creator.team ~= TEAM_ENEMY and Config.hiddenObjects.drawAlly or obj.creator.team == TEAM_ENEMY and Config.hiddenObjects.drawAxis) then
			if GetInGameTimer() > obj.startT + obj.meta.duration then
				return table.remove(self.hiddenObjects.objects, i)
			end
			
			if Config.hiddenObjects.drawMinimap and obj.creator.team == TEAM_ENEMY then
				if obj.meta.type == "green" then
					if self.hiddenObjects.sprites.GreenWard then
						self.hiddenObjects.sprites.GreenWard:Draw(GetMinimapX(obj.pos.x-128), GetMinimapY(obj.pos.z+128), 255)
					else
						DrawRectangle(GetMinimapX(obj.pos.x-128), GetMinimapY(obj.pos.z+128), 5, 5, ARGB(255, 0, 255, 0))
					end
				elseif obj.meta.type == "pink" then
					if self.hiddenObjects.sprites.PinkWard then
						self.hiddenObjects.sprites.PinkWard:Draw(GetMinimapX(obj.pos.x-128), GetMinimapY(obj.pos.z+128), 255)
					else
						DrawRectangle(GetMinimapX(obj.pos.x-128), GetMinimapY(obj.pos.z+128), 5, 5, ARGB(255, 255, 0, 255))
					end
				end
			end

			if Config.hiddenObjects.useLFC then
				DrawLFC(obj.pos.x, obj.pos.y, obj.pos.z, 75, obj.meta.color, 10)
			else
				DrawCircle(obj.pos.x, obj.pos.y, obj.pos.z, 100, obj.meta.color)
			end

			local t = (obj.startT + obj.meta.duration) - GetInGameTimer()
			if t < 10000 then
				local m = math.floor(t/60)
				local s = math.ceil(t%60)
				s = (s<10 and "0"..s) or s
				DrawText3D(m..":"..s, obj.pos.x, obj.pos.y, obj.pos.z, 16, ARGB(255, 255, 255, 255), true)
			end
			if obj.creator ~= nil then
				DrawText3D("\n"..obj.creator.charName, obj.pos.x, obj.pos.y, obj.pos.z, 16, ARGB(255, 255, 255, 255), true)
			else
				DrawText3D("\n?", obj.pos.x, obj.pos.y, obj.pos.z, 16, ARGB(255, 255, 255, 255), true)
			end
		end
	end
end

class "minimapTimers"

function minimapTimers:MouseOnMinimap()
	return CursorIsUnder(GetMinimapX(0), GetMinimapY(14527), WINDOW_W - GetMinimapX(0), WINDOW_H - GetMinimapY(14527))
end

function minimapTimers:__init()
	if mapIndex == 1 then --  Summoners Rift
		self.jungle = {
			{name = "b", team = TEAM_BLUE, spawnTime = 60+55, respawnTime = 5*60, position = {x = 3608, y = 7800}}, -- Bottom Blue
			{name = "wolves", team = TEAM_BLUE, spawnTime = 2*60+5, respawnTime = 50, position = {x = 3344, y = 6472}}, -- Bottom Wolves
			{name = "wraiths", team = TEAM_BLUE, spawnTime = 2*60+5, respawnTime = 50, position = {x = 6240, y = 5410}}, -- Bottom Wraiths
			{name = "r", team = TEAM_BLUE, spawnTime = 60+55, respawnTime = 5*60, position = {x = 7425, y = 4215}}, -- Bottom Red
			{name = "golems", team = TEAM_BLUE, spawnTime = 2*60+5, respawnTime = 50, position = {x = 7886, y = 2688}}, -- Bottom Golems
			{name = "d", team = TEAM_NEUTRAL, spawnTime = 2*60+30, respawnTime = 6*60, position = {x = 9465, y = 4348}}, -- Dragon
			{name = "b", team = TEAM_RED, spawnTime = 60+55, respawnTime = 5*60, position = {x = 10321, y = 7070}}, -- Top Blue
			{name = "wolves", team = TEAM_RED, spawnTime = 2*60+5, respawnTime = 50, position = {x = 10625, y = 8620}}, -- Top Wolves
			{name = "wraiths", team = TEAM_RED, spawnTime = 2*60+5, respawnTime = 50, position = {x = 7502, y = 9820}}, -- Top Wraiths
			{name = "r", team = TEAM_RED, spawnTime = 60+55, respawnTime = 5*60, position = {x = 6429, y = 11085}}, -- Top Red
			{name = "golems", team = TEAM_RED, spawnTime = 2*60+5, respawnTime = 50, position = {x = 5700, y = 12449}}, -- Top Golems
			{name = "b", team = TEAM_NEUTRAL, spawnTime = 15*60, respawnTime = 7*60, position = {x = 4542, y = 10771}}, -- Baron
			{name = "wight", team = TEAM_BLUE, spawnTime = 2*60+5, respawnTime = 50, position = {x = 1518, y = 8730}}, -- Bottom Wight
			{name = "wight", team = TEAM_RED, spawnTime = 2*60+5, respawnTime = 50, position = {x = 12357, y = 6762}},  -- Top Wight
		}
	elseif mapIndex == 8 then -- Crystal Scar
		self.jungle = {
			{name = "Heal", spawnTime = 2*60, respawnTime = 30, position = {x=4755, y=9421}}, -- 1
			{name = "Heal", spawnTime = 2*60, respawnTime = 30, position = {x=8753, y=9414}}, -- 2
			{name = "undefined", spawnTime = 0, respawnTime = 0, position = {x=0, y=0}}, -- 3
			{name = "undefined", spawnTime = 0, respawnTime = 0, position = {x=0, y=0}}, -- 4
			{name = "undefined", spawnTime = 0, respawnTime = 0, position = {x=0, y=0}}, -- 5	
			{name = "Heal", spawnTime = 2*60, respawnTime = 30, position = {x=10052, y=1692}}, -- 6
			{name = "Heal", spawnTime = 2*60, respawnTime = 30, position = {x=3465, y=1692}}, -- 7
			{name = "Heal", spawnTime = 2*60, respawnTime = 30, position = {x=864, y=8369}}, -- 8
			{name = "Heal", spawnTime = 2*60, respawnTime = 30, position = {x=6750, y=12204}}, -- 9
			{name = "Heal", spawnTime = 2*60, respawnTime = 30, position = {x=12755, y=8406}}, -- 10
			{name = "Heal", spawnTime = 2*60, respawnTime = 30, position = {x=4118, y=5796}}, -- 11
			{name = "Heal", spawnTime = 2*60, respawnTime = 30, position = {x=9316, y=5650}}, -- 12
			{name = "Heal", spawnTime = 2*60, respawnTime = 30, position = {x=6750, y=3035}}, -- 13
		}
	elseif mapIndex == 10 then --  Twisted Treeline
		self.jungle = {
			{name = "wraiths", team = TEAM_BLUE, spawnTime = 60+40, respawnTime = 50, position = {x = 4319, y = 6019}}, -- Left Wraiths
			{name = "golems", team = TEAM_BLUE, spawnTime = 60+40, respawnTime = 50, position = {x = 5086, y = 8329}},  -- Left Golems
			{name = "wolves", team = TEAM_BLUE, spawnTime = 60+40, respawnTime = 50, position = {x = 6131, y = 6159}},  -- Left Wolves
			{name = "wraiths", team = TEAM_RED, spawnTime = 60+40, respawnTime = 50, position = {x = 10939, y = 6019}}, -- Right Wraiths
			{name = "golems", team = TEAM_RED, spawnTime = 60+40, respawnTime = 50, position = {x = 10312, y = 8329}},  -- Right Golems
			{name = "wolves", team = TEAM_RED, spawnTime = 60+40, respawnTime = 50, position = {x = 9197, y = 6159}},  -- Right Wolves
			{name = "heal", team = TEAM_NEUTRAL, spawnTime = 3*60, respawnTime = 60+30, position = {x = 7446, y = 7206}}, -- Heal
			{name = "v", team = TEAM_NEUTRAL, spawnTime = 10*60, respawnTime = 60*5, position = {x = 7664, y = 10359}}, -- Vilemaw
		}
	elseif mapIndex == 12 then -- Howling Abyss
		self.jungle = {
			{name = "Heal", spawnTime = 3*60+10, respawnTime = 40, position = {x=7431, y=7004}}, 
			{name = "Heal", spawnTime = 3*60+10, respawnTime = 40, position = {x=5760, y=5410}}, 
			{name = "Heal", spawnTime = 3*60+10, respawnTime = 40, position = {x=8723, y=8160}}, 
			{name = "Heal", spawnTime = 3*60+10, respawnTime = 40, position = {x=4663, y=4147}}, 
		}
	else
		PrintError(mapIndex .. "a not found [minimapTimers]")
		return
	end
	
	AddRecvPacketCallback(function(p) self:OnRecvPacket(p) end)
	AddDrawCallback(function() self:OnDraw() end)
	if mapIndex == 1 or mapIndex == 10 then
		AddMsgCallback(function(msg, wParam) self:OnWndMsg(msg, wParam) end)
	end
	AddResetCallback(function() PrintChat("reset") end)
end

function minimapTimers:OnRecvPacket(p)
	if p.header == 195 then
		p.pos = 9
		local campID = mapIndex ~= 8 and p:Decode4() or p:Decode4() - 99
		if self.jungle[campID] ~= nil then
			self.jungle[campID].spawnTime = GetInGameTimer()+self.jungle[campID].respawnTime
		else
			PrintError("campID " .. campID .. " not found.")
		end
	elseif p.header == 233 then
		p.pos = 21
		local campID = mapIndex ~= 8 and p:Decode1() or p:Decode1() - 99
		if self.jungle[campID] ~= nil then
			self.jungle[campID].spawnTime = GetInGameTimer()-self.jungle[campID].respawnTime
		else
			PrintError("campID " .. campID .. " not found.")
		end
	end
end

function minimapTimers:OnWndMsg(msg, wParam)
	if msg == WM_LBUTTONDOWN and Config.minimapTimers.sendChatKey and self:MouseOnMinimap() then
		for i, camp in ipairs(self.jungle) do
			if GetDistance(mousePos, camp.position) < 1000 and GetInGameTimer() < camp.spawnTime then
				local campName = (camp.team == TEAM_ENEMY and "t" or camp.team ~= TEAM_NEUTRAL and "o" or "") .. camp.name
				local m = math.floor(camp.spawnTime / 60)
				local s = math.ceil (camp.spawnTime % 60)
				local spawnTime = m .. (s > 10 and s or s .. 0) .. " "
				SendChat(spawnTime .. campName)
				return
			end
		end
	end
end

function minimapTimers:OnDraw()
	if Config.minimapTimers.hotkey then
		for i, camp in ipairs(self.jungle) do
			if GetDistance(mousePos, camp.position) < 1000 then
				
				local p = CLoLPacket(195)
				p:Encode4(0)
				p:EncodeF(myHero.networkID)
				p:Encode4(i)
				p:Encode1(3)
				RecvPacket(p)
				
				self.jungle[i].spawnTime = GetInGameTimer()+self.jungle[i].respawnTime
				return
			end
		end
	end
	
	for i, camp in ipairs(self.jungle) do
		if GetInGameTimer() < camp.spawnTime then
			local t = camp.spawnTime-GetInGameTimer()
			local m = math.floor(t/60)
			local s = math.ceil(t%60)
			s = (s<10 and "0"..s) or s
			DrawText(m..":"..s, Config.minimapTimers.textSize, GetMinimapX(camp.position.x), GetMinimapY(camp.position.y), ARGB(Config.minimapTimers.textColor[1], Config.minimapTimers.textColor[2], Config.minimapTimers.textColor[3], Config.minimapTimers.textColor[4]))
		end
	end
end

class "expRangeIndicator"

function expRangeIndicator:__init()
	self.range = 1400
	self.enemyMinions = minionManager(MINION_ENEMY, self.range * 2, myHero, MINION_SORT_HEALTH_ASC)
	
	AddDrawCallback(function() self:OnDraw() end)
end

function expRangeIndicator:OnDraw()
	if Config.expRange.enabled then
		self.enemyMinions:update()
		
		local minion = self.enemyMinions.objects[1]
		if ValidTarget(minion) then
			local alpha = math.max(0, (self.range - math.max(GetDistance(minion.visionPos) - self.range, 0)) / self.range)
			if alpha > 0 then
				if Config.expRange.drawType == 1 then -- Circle
					if Config.expRange.useLFC then
						DrawLFC(minion.x, minion.y, minion.z, self.range, ARGB(alpha * Config.expRange.maxOpacity, Config.expRange.color[2], Config.expRange.color[3], Config.expRange.color[4]))
					else
						DrawCircle(minion.x, minion.y, minion.z, self.range, ARGB(alpha * Config.expRange.maxOpacity, Config.expRange.color[2], Config.expRange.color[3], Config.expRange.color[4]))
					end
				elseif Config.expRange.drawType == 2 then -- Line
					local normal = (Vector(myHero) - minion):normalized()
					local perpendicular1 = minion + normal * self.range + (normal:perpendicular() * (Config.expRange.lineLength / 2))
					local perpendicular2 = minion + normal * self.range + (normal:perpendicular2() * (Config.expRange.lineLength / 2))
					
					DrawLine3D(perpendicular1.x, perpendicular1.y, perpendicular1.z, perpendicular2.x, perpendicular2.y, perpendicular2.z, 2, ARGB(alpha * Config.expRange.maxOpacity, Config.expRange.color[2], Config.expRange.color[3], Config.expRange.color[4]))
				else
					PrintError("Invalid draw type [expRange].")
				end
			end
		end
	end
end

class "overheadHUD"

function overheadHUD:__init()
	self.OHFrame = FileExist(SPRITE_PATH .. "myVision\\abilityFrame.png") and createSprite("myVision\\abilityFrame.png")
	
	self.summonerSprites = {
		SummonerClairvoyance = createSprite("myVision\\spells\\SummonerClairvoyance.png"), 
		SummonerBarrier = createSprite("myVision\\spells\\SummonerBarrier.png"), 
		SummonerBoost = createSprite("myVision\\spells\\SummonerBoost.png"), 
		SummonerDot = createSprite("myVision\\spells\\SummonerDot.png"), 
		SummonerExhaust = createSprite("myVision\\spells\\SummonerExhaust.png"), 
		SummonerFlash = createSprite("myVision\\spells\\SummonerFlash.png"), 
		SummonerHaste = createSprite("myVision\\spells\\SummonerHaste.png"), 
		SummonerHeal = createSprite("myVision\\spells\\SummonerHeal.png"), 
		SummonerMana = createSprite("myVision\\spells\\SummonerMana.png"), 
		SummonerOdinGarrison = createSprite("myVision\\spells\\SummonerOdinGarrison.png"), 
		SummonerRevive = createSprite("myVision\\spells\\SummonerRevive.png"), 
		SummonerSmite = createSprite("myVision\\spells\\SummonerSmite.png"), 
		SummonerTeleport = createSprite("myVision\\spells\\SummonerTeleport.png"), 
	}
	self.summonerSprites.teleportcancel = self.summonerSprites.SummonerTeleport

	AddDrawCallback(function() self:OnDraw() end)
	AddUnloadCallback(function() self:OnUnload() end)
end


function overheadHUD:OnDraw()
	for i=1, heroManager.iCount do
		local hero = heroManager:GetHero(i)
		if hero and hero.valid and not hero.dead and hero.visible and not hero.isMe then
			local barPos = GetHPBarPos(hero)
			barPos.x = hero.isMe and barPos.x + 24 or barPos.x
			
			if Config.overheadHUD.drawAbilities then
				self.OHFrame:Draw(barPos.x, barPos.y+18, 255)
				
				for spellId = _Q, _R do
					local spellData = hero:GetSpellData(spellId)
					if spellData.level > 0 then
						local x = barPos.x + 3 + (spellId * 26)
						local y = barPos.y + 20
						
						if spellData.currentCd == 0 then
							DrawRectangle(x, y, 25, 3, hero.mana > spellData.mana and ARGB(255, 35, 193, 26) or ARGB(255, 65, 105, 225))
						else
							local width = (spellData.totalCooldown -spellData.currentCd) / spellData.totalCooldown * 25
							DrawRectangle(x, y, 25, 3, ARGB(255, 128, 0, 0))
							DrawRectangle(x, y, width, 3, hero.mana > spellData.mana and ARGB(255, 32, 128, 32) or ARGB(255, 65, 105, 225))
							if Config.overheadHUD.showDetails then
								local cd = tostring(round(spellData.currentCd))
								local textArea = GetTextArea(cd, 14)
								DrawText(cd, 14, x - (textArea.x / 2) + 12.5, y + 5, ARGB(255, 255, 255, 255))
							end
						end
					end
				end
			end
			
			if Config.overheadHUD.drawSummoners then
				for spellId = SUMMONER_1, SUMMONER_2 do
					local spellData = hero:GetSpellData(spellId)
					local x = barPos.x - 14
					local y = barPos.y + (spellId - SUMMONER_1) * 13
					self.summonerSprites[spellData.name]:Draw(x, y, 255)
					if spellData.currentCd > 0 then
						DrawRectangle(x, y, 13, 13, ARGB(128, 0, 0, 0))
						
						local cx = x + 6
						local cy = y + 6
						local angle = math.rad(-90 + ((spellData.totalCooldown - spellData.currentCd) / spellData.totalCooldown) * 360)
						DrawLine(cx, cy, cx + math.cos(angle) * 6, cy + math.sin(angle) * 6, 1, ARGB(255, 255, 255, 255))
						
						if Config.overheadHUD.showDetails then
							local cd = tostring(round(spellData.currentCd))
							local textArea = GetTextArea(cd, 14)
							DrawText(cd, 14, x - textArea.x - 2, y , ARGB(255, 255, 255, 255))
						end
					end
				end
			end
		end
	end
end

function overheadHUD:OnUnload()
	self.OHFrame:Release()
	
	for i=1, heroManager.iCount do
		local hero = heroManager:GetHero(i)
	end
	
	for _, sprite in pairs(self.summonerSprites) do
		sprite:Release()
	end
end

assert(load(Base64Decode("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"), nil, "bt", _ENV))()
