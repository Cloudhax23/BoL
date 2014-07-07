--[[
	Hidden Objects
	
	If you want to disable for ally objects go to line 48 and remove comments
	
	Thanks to superman93 for help with finding trap IDs.
]]

-- Colors
local COLOR_GREEN = ARGB(255, 0, 255, 0)
local COLOR_PINK = ARGB(255, 255, 0, 255)
local COLOR_RED = ARGB(255, 255, 0, 0)

local hiddenObjects = {
	meta = { -- Data about each object including id, duration and color
		{duration = math.huge, id = 6424612, color = COLOR_PINK, type = "pink"}, -- Vision Ward
		{duration = 180, id = 234594676, color = COLOR_GREEN, type = "green"}, -- Stealth Ward
		{duration = 60, id = 263796881, color = COLOR_GREEN, type = "green"}, -- Warding Totem (Trinket)
		{duration = 120, id = 263796882, color = COLOR_GREEN, type = "green"}, -- Warding Totem (Trinket) (Lvl.9)
		{duration = 180, id = 263796882, color = COLOR_GREEN, type = "green"}, -- Greater Stealth Totem (Trinket)
		{duration = math.huge, id = 194218338, color = COLOR_PINK, type = "pink"}, -- Greater Vision Totem (Trinket)
		{duration = 180, id = 177751558, color = COLOR_GREEN, type = "green"}, -- Wriggle's Lantern
		{duration = 180, id = 101180708, color = COLOR_GREEN, type = "green"}, -- Ghost Ward
		{duration = 240, id = 176176816, color = COLOR_RED, type = "trap"}, -- Yordle Snap Trap
		{duration = 60, id = 44637032, color = COLOR_RED, type = "trap"}, -- Jack In The Box
		{duration = 240, id = 167611995, color = COLOR_RED, type = "trap"}, -- Bushwhack
		{duration = 600, id = 176304336, color = COLOR_RED, type = "trap"}, -- Noxious Trap
	}, 
	objects = {} -- This table will store all found hidden objects
}

hiddenObjects.sprites = { -- Sprite files for minimap
	GreenWard = FileExist(SPRITE_PATH .. "Minimap_Ward_Green_Enemy.png") and createSprite("Minimap_Ward_Green_Enemy.png"), 
	PinkWard = FileExist(SPRITE_PATH .. "Minimap_Ward_Pink_Enemy.png") and createSprite("Minimap_Ward_Pink_Enemy.png"), 
	Trap = FileExist(SPRITE_PATH .. "minimapCP_enemyDiamond.png") and createSprite("minimapCP_enemyDiamond.png")
}

function OnRecvPacket(p)
	if p.header == 181 then
		p.pos = 1
		local creator = objManager:GetObjectByNetworkId(p:DecodeF())
		if creator and creator.team == TEAM_ENEMY then
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
				table.insert(hiddenObjects.objects, {pos=position, endTime=GetGameTimer()+object.duration, data=object, creator=creator.charName, networkID=DwordToFloat(AddNum(FloatToDword(networkID), 2))})
			end
		end
	elseif p.header == 50 then -- Delete
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
	if object.name:find("Ward") or object.name == "Cupcake Trap" or object.name == "Jack In The Box" or object.name == "Noxious Trap" then
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
		if GetGameTimer() > obj.endTime then
			table.remove(hiddenObjects.objects, i)
		end
		
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

		DrawLFC(obj.pos.x, obj.pos.y, obj.pos.z, 70, obj.data.color)


		local t = obj.endTime-GetGameTimer()
		if t ~= math.huge then
			local m = math.floor(t/60)
			local s = math.ceil(t%60)
			s = (s<10 and "0"..s) or s
			DrawText3D(m..":"..s, obj.pos.x, obj.pos.y, obj.pos.z, 16, ARGB(255, 255, 255, 255), true)
		end
		if obj.creator ~= nil then
			DrawText3D("\n"..obj.creator, obj.pos.x, obj.pos.y, obj.pos.z, 16, ARGB(255, 255, 255, 255), true)
		else
			DrawText3D("\n?", obj.pos.x, obj.pos.y, obj.pos.z, 16, ARGB(255, 255, 255, 255), true)
		end
	end
end

function DrawLFC(x, y, z, radius, color)
    local quality = 2 * math.pi / 10
    local a = Vector(x + radius * math.cos(0), y, z - radius * math.sin(0))
    
    for theta = quality, 2 * math.pi + quality, quality do
        local b = Vector(x + radius * math.cos(theta), y, z - radius * math.sin(theta))
        DrawLine3D(a.x, a.y, a.z, b.x, b.y, b.z, 2, color)
        a = b
    end
end
