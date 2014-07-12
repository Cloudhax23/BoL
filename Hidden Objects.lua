--[[
	Hidden Objects
	
	Thanks to superman93 for help with finding trap IDs.
]]

-- Colors
local COLOR_GREEN = ARGB(255, 0, 255, 0)
local COLOR_PINK = ARGB(255, 255, 0, 255)
local COLOR_RED = ARGB(255, 255, 0, 0)

local hiddenObjects = {
	meta = {
		{duration = 25000, id = 6424612, objectName = "VisionWard", color = COLOR_PINK, type = "pink"}, -- Vision Ward
		{duration = 180, id = 234594676, objectName = "SightWard", color = COLOR_GREEN, type = "green"}, -- Stealth Ward
		{duration = 60, id = 263796881, objectName = "Global_Trinket_Yellow.troy", color = COLOR_GREEN, type = "green"}, -- Warding Totem (Trinket)
		{duration = 120, id = 263796882, objectName = "SightWard", color = COLOR_GREEN, type = "green"}, -- Warding Totem (Trinket) (Lvl.9)
		{duration = 180, id = 263796882, objectName = "SightWard", color = COLOR_GREEN, type = "green"}, -- Greater Stealth Totem (Trinket)
		{duration = 25000, id = 194218338, objectName = "VisionWard", color = COLOR_PINK, type = "pink"}, -- Greater Vision Totem (Trinket)
		{duration = 180, id = 177751558, objectName = "SightWard", color = COLOR_GREEN, type = "green"}, -- Wriggle's Lantern
		{duration = 180, id = 135609454, objectName = "SightWard", color = COLOR_GREEN, type = "green"}, -- Quill Coat
		{duration = 180, id = 101180708, objectName = "VisionWard", color = COLOR_GREEN, type = "green"}, -- Ghost Ward
		{duration = 240, id = 176176816, objectName = "", color = COLOR_RED, type = "trap"}, -- Yordle Snap Trap
		{duration = 60, id = 44637032, objectName = "", color = COLOR_RED, type = "trap"}, -- Jack In The Box
		{duration = 240, id = 167611995, objectName = "", color = COLOR_RED, type = "trap"}, -- Bushwhack
		{duration = 600, id = 176304336, objectName = "", color = COLOR_RED, type = "trap"}, -- Noxious Trap
	}, 
	objects = {}
}

hiddenObjects.sprites = {
	GreenWard = FileExist(SPRITE_PATH .. "Minimap_Ward_Green_Enemy.png") and createSprite("Minimap_Ward_Green_Enemy.png"), 
	PinkWard = FileExist(SPRITE_PATH .. "Minimap_Ward_Pink_Enemy.png") and createSprite("Minimap_Ward_Pink_Enemy.png"), 
	Trap = FileExist(SPRITE_PATH .. "minimapCP_enemyDiamond.png") and createSprite("minimapCP_enemyDiamond.png")
}

function OnLoad()
	Config = scriptConfig("Hidden Objects", "hiddenObjects")
	Config:addParam("drawAllyWards", "Draw ally wards", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("drawMinimap", "Draw on minimap", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("useFOW", "Disable FOW on ward radius", SCRIPT_PARAM_ONOFF, false)
	Config:addParam("useLFC", "Use lag-free circles", SCRIPT_PARAM_ONOFF, true)
end

function OnRecvPacket(p)
	if p.header == 181 then
		p.pos = 1
		local creator = objManager:GetObjectByNetworkId(p:DecodeF())
		if creator then
			p.pos = 12
			local id = p:Decode4()
			p.pos = 37
			local networkID = p:DecodeF()
			p.pos = 53
			local position = {x = p:DecodeF(), y = p:DecodeF(), z = p:DecodeF()}

			local object
			for _, obj in pairs(hiddenObjects.meta) do
				if id == obj.id then
					object = obj
					break
				end
			end
			
			if object then
				networkID = DwordToFloat(AddNum(FloatToDword(networkID), 2))
				table.insert(hiddenObjects.objects, {pos=position, endTime=GetGameTimer()+object.duration, data=object, creator=creator, networkID=networkID})
				
				DelayAction(function()
					for _, obj in pairs(hiddenObjects.objects) do
						if obj.networkID == networkID then
							local object = objManager:GetObjectByNetworkId(networkID)
							if object and object.valid then
								obj.pos = Vector(object.x, object.y, object.z)
							end
							return
						end
					end
				end, 1)
				
				if Config.useFOW and object.type ~= "trap" then
					DisableFOW(myHero.team, AddNum(FloatToDword(networkID), -2), position, object.duration)
				end
			end
		end
	elseif p.header == 178 then
		p.pos = 1
		local networkID = p:DecodeF()
		local object = objManager:GetObjectByNetworkId(networkID)
		for _, obj in pairs(hiddenObjects.objects) do
			if obj.networkID == networkID then
				obj.pos = Vector(object.x, object.y, object.z)
				return
			end
		end
	elseif p.header == 50 then
		p.pos = 1
		local networkID = p:DecodeF()
		for i, obj in ipairs(hiddenObjects.objects) do
			if obj.networkID and obj.networkID == networkID then
				table.remove(hiddenObjects.objects, i)
				break
			end
		end
	end
end

function OnDeleteObj(object)
	if object and object.valid and object.name:find("Ward") or object.name == "Cupcake Trap" or object.name == "Jack In The Box" or object.name == "Noxious Trap" then
		for i, obj in ipairs(hiddenObjects.objects) do
			if GetDistance(object, obj.pos) < 5 then
				table.remove(hiddenObjects.objects, i)
				return
			end
		end
	end
end

function OnDraw()
	for i, obj in pairs(hiddenObjects.objects) do
		if (Config.drawAllyWards and obj.creator.team ~= TEAM_ENEMY or obj.creator.team == TEAM_ENEMY) then
			if GetGameTimer() > obj.endTime then
				table.remove(hiddenObjects.objects, i)
			end			
			
			if Config.drawMinimap then
				if obj.data.type == "green" then
					if hiddenObjects.sprites.GreenWard then
						hiddenObjects.sprites.GreenWard:Draw(GetMinimapX(obj.pos.x-128), GetMinimapY(obj.pos.z+128), 255)
					else
						DrawRectangle(GetMinimapX(obj.pos.x-128), GetMinimapY(obj.pos.z+128), 5, 5, ARGB(255, 0, 255, 0))
					end
				elseif obj.data.type == "pink" then
					if hiddenObjects.sprites.PinkWard then
						hiddenObjects.sprites.PinkWard:Draw(GetMinimapX(obj.pos.x-128), GetMinimapY(obj.pos.z+128), 255)
					else
						DrawRectangle(GetMinimapX(obj.pos.x-128), GetMinimapY(obj.pos.z+128), 5, 5, ARGB(255, 255, 0, 255))
					end
				else
					if hiddenObjects.sprites.Trap then
						hiddenObjects.sprites.Trap:Draw(GetMinimapX(obj.pos.x-128), GetMinimapY(obj.pos.z+128), 255)
					else
						DrawRectangle(GetMinimapX(obj.pos.x-128), GetMinimapY(obj.pos.z+128), 5, 5, ARGB(255, 255, 0, 0))
					end
				end
			end

			if Config.useLFC then
				DrawCircle3D(obj.pos.x, obj.pos.y, obj.pos.z, 75, 2, obj.data.color, 10)
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

function DisableFOW(team, networkID, pos, duration)
	local p = CLoLPacket(0x23)
	p:Encode4(0)
	p:Encode1(myHero.team)
	p:Encode4(0)
	p:Encode2(0)
	p:Encode1(0)
	p:Encode4(0xFFFFFFFE)
	p:Encode4(networkID)
	p:Encode4(0)
	p:Encode4(0)
	p:EncodeF(myHero.x)
	p:EncodeF(myHero.z)
	p:EncodeF(duration)
	p:Encode4(0x40A00000)
	p:Encode4(0xBF800000)
	p:Encode4(0x3F800000)
	p:Encode4(0)
	if duration ~= 25000 then
		p:Encode4(3)
		p:Encode4(0x44610000)
	else
		p:Encode4(7)
		p:Encode4(0x44A8C000)
	end
	RecvPacket(p)
end
