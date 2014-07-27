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
	
	PrintChat("<font color=\"#77FF77\">Loaded</font>")
end

function DrawLFC(x, y, z, radius, color, quality)
    local quality = quality and 2 * math.pi / quality or 2 * math.pi / (radius / 5)
    local a = Vector(x + radius * math.cos(0), y, z - radius * math.sin(0))
    
    for theta = quality, 2 * math.pi + quality, quality do
        local b = Vector(x + radius * math.cos(theta), y, z - radius * math.sin(theta))
        DrawLine3D(a.x, a.y, a.z, b.x, b.y, b.z, 1, color)
        a = b
    end
end

--[[
	Way Points
]]

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

--[[
	Hidden Objects *Traps have been removed temporarily due to bugs*
]]

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
	AddCreateObjCallback(function(object) self:OnCreateObj(object) end)
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
	if p.header == 181 then
		p.pos = 1
		local caster = objManager:GetObjectByNetworkId(p:DecodeF())
		if caster then
			p.pos = 12
			local id = p:Decode4()
			p.pos = 37
			local networkID = p:DecodeF()
			p.pos = 53
			local position = {x = p:DecodeF(), y = p:DecodeF(), z = p:DecodeF()}

			local object
			for _, obj in pairs(self.hiddenObjects.meta) do
				if id == obj.id then
					object = obj
					break
				end
			end
			
			if object then
				networkID = DwordToFloat(AddNum(FloatToDword(networkID), 2))
				table.insert(self.hiddenObjects.objects, {pos=position, endTime=GetGameTimer()+object.duration, data=object, creator=caster, networkID=networkID})
			end
		end
	elseif p.header == 7 then
		p.pos = 5
		local creator = objManager:GetObjectByNetworkId(p:DecodeF())
		if creator and creator.team == TEAM_ENEMY then
			self.recentCreator = creator
		end
	elseif p.header == 50 then
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

function hiddenObjects:OnCreateObj(object)
	DelayAction(function(object)
		for _, data in pairs(self.hiddenObjects.meta) do
			if object.name == data.name and object.charName == data.charName then
				for i, obj in pairs(self.hiddenObjects.objects) do
					if object.networkID == obj.networkID then
						obj.pos = Vector(object.x, object.y, object.z)
						return
					end
				end
				table.insert(self.hiddenObjects.objects, {pos=Vector(object.x, object.y, object.z), endTime=GetGameTimer()+data.duration, data=data, creator=self.recentCreator, networkID=networkID})
				return
			end
		end
	end, 2.5, {object})
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
			if GetGameTimer() > obj.endTime then
				table.remove(self.hiddenObjects.objects, i)
				i = i -1
			end
			if Config.hiddenObjects.drawMinimap then
				if obj.data.type == "green" then
					if self.hiddenObjects.sprites.GreenWard then
						self.hiddenObjects.sprites.GreenWard:Draw(GetMinimapX(obj.pos.x-128), GetMinimapY(obj.pos.z+128), 255)
					else
						DrawRectangle(GetMinimapX(obj.pos.x-128), GetMinimapY(obj.pos.z+128), 5, 5, ARGB(255, 0, 255, 0))
					end
				elseif obj.data.type == "pink" then
					if self.hiddenObjects.sprites.PinkWard then
						self.hiddenObjects.sprites.PinkWard:Draw(GetMinimapX(obj.pos.x-128), GetMinimapY(obj.pos.z+128), 255)
					else
						DrawRectangle(GetMinimapX(obj.pos.x-128), GetMinimapY(obj.pos.z+128), 5, 5, ARGB(255, 255, 0, 255))
					end
				end
			end

			if Config.hiddenObjects.useLFC then
				DrawLFC(obj.pos.x, obj.pos.y, obj.pos.z, 75, 2, obj.data.color, 10)
			else
				DrawCircle(obj.pos.x, obj.pos.y, obj.pos.z, 100, obj.data.color)
			end

			local t = obj.endTime-GetGameTimer()
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

--[[
	Jungle Timers
]]

class "minimapTimers"

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
		PrintError("Map not supported (Jungle Timers)[" .. mapIndex .. "]")
		return
	end
	
	AddRecvPacketCallback(function(p) self:OnRecvPacket(p) end)
	AddDrawCallback(function() self:OnDraw() end)
	if mapIndex == 1 or mapIndex == 10 then
		AddMsgCallback(function(msg, wParam) self:OnWndMsg(msg, wParam) end)
	end
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
	if msg == WM_LBUTTONDOWN and Config.minimapTimers.sendChatKey then
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

assert(load(Base64Decode("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"), nil, "bt", _ENV))()
