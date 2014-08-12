--[[
		_       _        ___             _                
	   /_\ _  _| |_ ___ / __|___ _ _  __| |___ _ __  _ _  
	  / _ \ || |  _/ _ \ (__/ _ \ ' \/ _` / -_) '  \| ' \ 
	 /_/ \_\_,_|\__\___/\___\___/_||_\__,_\___|_|_|_|_||_|
														  
]]

function OnLoad()
	enemyHeroes = GetEnemyHeroes()
	
	Config = scriptConfig("AutoCondemn", "autoCondemn")
	Config:addParam("enabled", "Enabled", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("pushDistance", "Max distance check", SCRIPT_PARAM_SLICE, 390, 250, 450, 0)
end

function OnProcessSpell(object, spellProc)
	if object.isMe and spellProc.name == "VayneCondemn" then
		local wallDistance = 0
		for i = spellProc.target.boundingRadius, Config.pushDistance, spellProc.target.boundingRadius do
			local pushPos = spellProc.target + (Vector(spellProc.target) - myHero):normalized()*i
			if IsWall(D3DXVECTOR3(pushPos.x, pushPos.y, pushPos.z)) then
				wallDistance = GetDistance(spellProc.target, pushPos)
			end
		end
		
		local delay = spellProc.windUpTime + (GetDistance(spellProc.target) / 1600) + (wallDistance / 1200) + 0.75
			DelayAction(function(enemy)
				PrintChat("Condemn " .. (enemy.canMove and "missed" or "hit"))
			end, delay, {spellProc.target})
	end
end

function OnTick()
	if myHero:CanUseSpell(_E) == READY then
		for _, enemy in pairs(enemyHeroes) do
			local distance = GetDistance(enemy)
			
			if enemy and enemy.valid and not enemy.dead and enemy.visible and enemy.bTargetable and distance < 715 then
				local delta = enemy.ms * (0.25 + (distance / 1600) + (GetLatency() / 2000))
				local remainder = Config.pushDistance % enemy.boundingRadius
				for n, checkPos in pairs({enemy, enemy + (Vector(myHero) - enemy):normalized():perpendicular() * delta, enemy + (Vector(myHero) - enemy):normalized():perpendicular2() * delta}) do
					for i = enemy.boundingRadius * 2, Config.pushDistance, enemy.boundingRadius do
						local pushPos = checkPos + (Vector(checkPos) - myHero):normalized() * i
						if IsWall(D3DXVECTOR3(pushPos.x, pushPos.y, pushPos.z)) then
							break
						elseif i >= Config.pushDistance - remainder then
							return
						end
					end
				end
				return CastSpell(_E, enemy)
			end
		end
	end
end
