--[[
	Jungle Timers
	
	If you think a jungle camp has been cleared but don't have vision of it, 
	press 'K' on camp (can also be done through minimap).
]]

local HOTKEY = 'K'

local jungle = {
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

function OnRecvPacket(p)
	if p.header == 195 then
		p.pos = 9
		local campID = p:Decode4()
		jungle[campID].spawnTime = GetGameTimer()+jungle[campID].respawnTime
	elseif p.header == 233 then
		p.pos = 21
		local campID = p:Decode1()
		if jungle[campID] ~= nil then
			jungle[campID].spawnTime = GetGameTimer()-jungle[campID].respawnTime
			PrintChat(jungle[campID].name .. " has spawned")
		end
	end
end

function OnWndMsg(msg, wParam)
	if msg == KEY_DOWN and wParam == GetKey(HOTKEY) then
		for i, camp in ipairs(jungle) do
			if GetDistance(mousePos, camp.position) < 1000 then
				
				local p = CLoLPacket(195)
				p:Encode4(0)
				p:EncodeF(myHero.networkID)
				p:Encode4(i)
				p:Encode1(3)
				RecvPacket(p)
				
				jungle[i].spawnTime = GetGameTimer()+jungle[i].respawnTime
			end
		end
	end
end

function OnDraw()
	for i, camp in ipairs(jungle) do
		if GetGameTimer() < camp.spawnTime then
			DrawText(tostring(math.ceil(camp.spawnTime-GetGameTimer())), 16, GetMinimapX(camp.position.x), GetMinimapY(camp.position.y), ARGB(255, 255, 255, 255))
		end
	end
end
