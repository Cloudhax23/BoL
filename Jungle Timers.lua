--[[
	Jungle Timers
	Thanks to TheSaint for helping with the Twisted Treeline map
	
	If you think a jungle camp has been cleared but don't have vision of it, press 'K' on camp
]]

local jungle = GetGame().map.index
local ServerTimer = GetGameTimer()
AddTickCallback(function() ServerTimer = ServerTimer + 0.01 end)

if jungle == 1 then
	jungle = {
		{name = "Blue", spawnTime = 115, respawnTime = 5*60, position = {x = 3608, y = 7800}}, -- Bottom Blue
		{name = "Wolves", spawnTime = 125, respawnTime = 50, position = {x = 3344, y = 6472}}, -- Bottom Wolves
		{name = "Wraiths", spawnTime = 125, respawnTime = 50, position = {x = 6240, y = 5410}}, -- Bottom Wraiths
		{name = "Red", spawnTime = 115, respawnTime = 5*60, position = {x = 7425, y = 4215}}, -- Bottom Red
		{name = "Golems", spawnTime = 125, respawnTime = 50, position = {x = 7886, y = 2688}}, -- Bottom Golems
		{name = "Dragon", spawnTime = 2*60+30, respawnTime = 6*60, position = {x = 9465, y = 4348}}, -- Dragon
		{name = "Blue", spawnTime = 115, respawnTime = 5*60, position = {x = 10321, y = 7070}}, -- Top Blue
		{name = "Wolves", spawnTime = 125, respawnTime = 50, position = {x = 10625, y = 8620}}, -- Top Wolves
		{name = "Wraiths", spawnTime = 125, respawnTime = 50, position = {x = 7502, y = 9820}}, -- Top Wraiths
		{name = "Red", spawnTime = 115, respawnTime = 5*60, position = {x = 6429, y = 11085}}, -- Top Red
		{name = "Golems", spawnTime = 125, respawnTime = 50, position = {x = 5700, y = 12449}}, -- Top Golems
		{name = "Baron", spawnTime = 15*60, respawnTime = 7*60, position = {x = 4542, y = 10771}}, -- Baron
		{name = "Wight", spawnTime = 125, respawnTime = 50, position = {x = 1518, y = 8730}}, -- Bottom Wight
		{name = "Wight", spawnTime = 125, respawnTime = 50, position = {x = 12357, y = 6762}},  -- Top Wight
	}
elseif jungle == 10 then
	jungle = {
		{name = "Wraiths", spawnTime = 100, respawnTime = 50, position = {x = 4319, y = 6019}}, -- Left Wraiths
		{name = "Golems", spawnTime = 100, respawnTime = 50, position = {x = 5086, y = 8329}},  -- Left Golems
		{name = "Wolves", spawnTime = 100, respawnTime = 50, position = {x = 6131, y = 6159}},  -- Left Wolves
		{name = "Wraiths", spawnTime = 100, respawnTime = 50, position = {x = 10939, y = 6019}}, -- Right Wraiths
		{name = "Golems", spawnTime = 100, respawnTime = 50, position = {x = 10312, y = 8329}},  -- Right Golems
		{name = "Wolves", spawnTime = 100, respawnTime = 50, position = {x = 9197, y = 6159}},  -- Right Wolves
		{name = "Heal", spawnTime = 180, respawnTime = 90, position = {x = 7446, y = 7206}}, -- Heal
		{name = "Vilemaw", spawnTime = 600, respawnTime = 60*5, position = {x = 7664, y = 10359}}, -- Vilemaw
	}
else
	PrintChat("Jungle Timers: Map not supported")
	return
end

function OnLoad()
	Config = scriptConfig("Jungle Timers", "jungleTimers")
	Config:addParam("hotkey", "Clear camp hotkey" , SCRIPT_PARAM_ONKEYDOWN, false, GetKey('K'))
	Config:addParam("textSize", "Minimap text size", SCRIPT_PARAM_SLICE, 14, 10, 20, 0)
	Config:addParam("textColor", "Minimap text color", SCRIPT_PARAM_COLOR, {255, 255, 255, 255})
end

function OnRecvPacket(p)
	if p.header == 195 then
		p.pos = 9
		local campID = p:Decode4()
		jungle[campID].spawnTime = ServerTimer+jungle[campID].respawnTime
	elseif p.header == 233 then
		p.pos = 21
		local campID = p:Decode1()
		if jungle[campID] ~= nil then
			jungle[campID].spawnTime = ServerTimer-jungle[campID].respawnTime
		end
	elseif p.header == 193 then
		p.pos = 5
		ServerTimer = p:DecodeF()
	end
end

function OnDraw()
	if Config.hotkey then
		for i, camp in ipairs(jungle) do
			if GetDistance(mousePos, camp.position) < 500 then
				
				local p = CLoLPacket(195)
				p:Encode4(0)
				p:EncodeF(myHero.networkID)
				p:Encode4(i)
				p:Encode1(3)
				RecvPacket(p)
				
				jungle[i].spawnTime = ServerTimer+jungle[i].respawnTime
			end
		end
	end
	
	for i, camp in ipairs(jungle) do
		if ServerTimer < camp.spawnTime then
			local t = camp.spawnTime-ServerTimer
			local m = math.floor(t/60)
			local s = math.ceil(t%60)
			s = (s<10 and "0"..s) or s
			DrawText(m..":"..s, Config.textSize, GetMinimapX(camp.position.x), GetMinimapY(camp.position.y), ARGB(Config.textColor[1], Config.textColor[2], Config.textColor[3], Config.textColor[4]))
		end
	end
end
