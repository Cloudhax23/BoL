--[ Orbwalk Assist by Jorj ]--

local lastAttack = 0
local windUpTime = 0

function OnProcessSpell(object, spellProc)
	if object.isMe and string.lower(spellProc.name):find("attack") then
		windUpTime = spellProc.windUpTime
	end
end

function OnSendPacket(p)
	if p.header == Packet.headers.S_MOVE then
		local latency = GetLatency()/2000
		local packet = Packet(p)
		local type = packet:get("type")
		if type == 3 then
			lastAttack = GetGameTimer()+latency
		elseif type == 2 and GetGameTimer()+latency < lastAttack+windUpTime+0.05 then
			packet:block()
			DelayAction(function()
				Packet('S_MOVE', {type=2, x=mousePos.x, y=mousePos.z}):send()
			end, windUpTime-latency)
		end
	end
end