--[[ 
	GameRAT: Vayne 0.3a
	
	What needs to be done?
	-Hero priority needs to be improved. The current hero priority algorithm does not take into account enemy damage capabilities and invulnerabilities.
	-Insert minions into table upon loading script.
	-Auto-condemn gap closers.
	-Issue with calcDamage function, this appears to have something to do with armor penetration/ghostblade
	-Stop attacking objects if mousePos and myHero are near tumbleExploit
	-Add more menu options. More customization.
]]--
if myHero.charName ~= "Vayne" then return end

-- Auto Update
local local_version = 14522
local server_version = tonumber(GetWebResult("raw.github.com", "/Jo7j/BoL/master/version/GRVayne.version"))
if server_version > local_version then
	PrintChat("Script is outdated. Updating to version: " .. server_version .. "...")
	PrintChat(SCRIPT_PATH .. "GRVayne.lua")
	
	DownloadFile("https://raw.github.com/Jo7j/BoL/master/GRVayne.lua", SCRIPT_PATH .. "GRVayne.lua", function()
            PrintChat("Script updated. Please reload (F9).")
        end)
end
-- End of Auto Update

--[ DATA ]--
function champTable()
	return { 
		Aatrox = {projSpeed = 0.348, yOffset=0}, 
		Ahri = {projSpeed = 1.75, yOffset=0}, 
		Akali = {projSpeed = 0.467, yOffset=0}, 
		Alistar = {projSpeed = 0, yOffset=0}, 
		Amumu = {projSpeed = 0.5, yOffset=0}, 
		Anivia = {projSpeed = 1.4, yOffset=0}, 
		Annie = {projSpeed = 1.2, yOffset=-13}, 
		Ashe = {projSpeed = 2.0, yOffset=17}, 
		Blitzcrank = {projSpeed = 0, yOffset=0}, 
		Brand = {projSpeed = 2.0, yOffset=0}, 
		Braum = {projSpeed = 0, yOffset=0}, 
		Caitlyn = {projSpeed = 2.5, yOffset=0}, 
		Cassiopeia = {projSpeed = 1.2, yOffset=-5}, 
		Chogath = {projSpeed = 0.5, yOffset=16}, 
		Corki = {projSpeed = 2.0, yOffset=0}, 
		Darius = {projSpeed = 0, yOffset=0}, 
		Diana = {projSpeed = 0.348, yOffset=0}, 
		DrMundo = {projSpeed = 0, yOffset=0}, 
		Draven = {projSpeed = 1.7, yOffset=0}, 
		Elise = {projSpeed = 1.6, yOffset=0}, 
		Evelynn = {projSpeed = 0.467, yOffset=0}, 
		Ezreal = {projSpeed = 2.0, yOffset=0}, 
		FiddleSticks = {projSpeed = 1.75, yOffset=7}, 
		Fiora = {projSpeed = 0.467, yOffset=0}, 
		Fizz = {projSpeed = 0, yOffset=0}, 
		Galio = {projSpeed = 1.0, yOffset=0}, 
		Gangplank = {projSpeed = 1.0, yOffset=0}, 
		Garen = {projSpeed = 0.348, yOffset=-13}, 
		Gragas = {projSpeed = 0, yOffset=0}, 
		Graves = {projSpeed = 3.0, yOffset=16}, 
		Hecarim = {projSpeed = 0.5, yOffset=0}, 
		Heimerdinger = {projSpeed = 1.5, yOffset=0}, 
		Irelia = {projSpeed = 0.467, yOffset=0}, 
		Janna = {projSpeed = 1.2, yOffset=0}, 
		JarvanIV = {projSpeed = 0.02, yOffset=0}, 
		Jax = {projSpeed = 0.4, yOffset=0}, 
		Jayce = {projSpeed = 0.348, yOffset=0}, 
		Jinx = {projSpeed = 2.75, yOffset=12}, 
		Karma = {projSpeed = 1.5, yOffset=0}, 
		Karthus = {projSpeed = 1.2, yOffset=0}, 
		Kassadin = {projSpeed = 0, yOffset=0}, 
		Katarina = {projSpeed = 0.467, yOffset=0}, 
		Kayle = {projSpeed = 1.8, yOffset=-55}, 
		Kennen = {projSpeed = 1.6, yOffset=0}, 
		Khazix = {projSpeed = 0.5, yOffset=0}, 
		KogMaw = {projSpeed = 1.8, yOffset=0}, 
		Leblanc = {projSpeed = 1.7, yOffset=0}, 
		LeeSin = {projSpeed = 0, yOffset=0}, 
		Leona = {projSpeed = 0.348, yOffset=-14}, 
		Lissandra = {projSpeed = 2.0, yOffset=0}, 
		Lucian = {projSpeed = 2.8, yOffset=-5}, 
		Lulu = {projSpeed = 1.45, yOffset=-13}, 
		Lux = {projSpeed = 1.6, yOffset=-14}, 
		Malphite = {projSpeed = 1.0, yOffset=-14}, 
		Malzahar = {projSpeed = 2.0, yOffset=-3}, 
		Maokai = {projSpeed = 0, yOffset=0}, 
		MasterYi = {projSpeed = 0, yOffset=-34}, 
		MissFortune = {projSpeed = 2.0, yOffset=-3}, 
		Mordekaiser = {projSpeed = 0, yOffset=0}, 
		Morgana = {projSpeed = 1.6, yOffset=-4}, 
		MonkeyKing = {projSpeed = 0.02, yOffset=-2}, 
		Nami = {projSpeed = 1.5, yOffset=0}, 
		Nasus = {projSpeed = 0, yOffset=16}, 
		Nautilus = {projSpeed = 1.0, yOffset=-14}, 
		Nidalee = {projSpeed = 1.75, yOffset=0}, 
		Nocturne = {projSpeed = 0, yOffset=0}, 
		Nunu = {projSpeed = 0.5, yOffset=-13}, 
		Olaf = {projSpeed = 0.348, yOffset=0}, 
		Orianna = {projSpeed = 1.45, yOffset=-7}, 
		Pantheon = {projSpeed = 0.02, yOffset=0}, 
		Poppy = {projSpeed = 0.5, yOffset=0}, 
		Quinn = {projSpeed = 2.0, yOffset=0}, 
		Rammus = {projSpeed = 0, yOffset=0}, 
		Renekton = {projSpeed = 0, yOffset=0}, 
		Rengar = {projSpeed = 0, yOffset=0}, 
		Riven = {projSpeed = 0.348, yOffset=0}, 
		Rumble = {projSpeed = 0.348, yOffset=0}, 
		Ryze = {projSpeed = 2.4, yOffset=-13}, 
		Sejuani = {projSpeed = 0.5, yOffset=0}, 
		Shaco = {projSpeed = 0, yOffset=0}, 
		Shen = {projSpeed = 0.4, yOffset=-12}, 
		Shyvana = {projSpeed = 0, yOffset=7}, 
		Singed = {projSpeed = 0.7, yOffset=0}, 
		Sion = {projSpeed = 0, yOffset=0}, 
		Sivir = {projSpeed = 1.75, yOffset=8}, 
		Skarner = {projSpeed = 0.5, yOffset=0}, 
		Sona = {projSpeed = 1.5, yOffset=-24}, 
		Soraka = {projSpeed = 1.0, yOffset=-23}, 
		Swain = {projSpeed = 1.6, yOffset=0}, 
		Syndra = {projSpeed = 1.8, yOffset=0}, 
		Talon = {projSpeed = 0, yOffset=0}, 
		Taric = {projSpeed = 0, yOffset=16}, 
		Teemo = {projSpeed = 1.3, yOffset=0}, 
		Thresh = {projSpeed = 0, yOffset=0}, 
		Tristana = {projSpeed = 2.25, yOffset=-3}, 
		Trundle = {projSpeed = 0.348, yOffset=45}, 
		Tryndamere = {projSpeed = 0.348, yOffset=0}, 
		TwistedFate = {projSpeed = 1.5, yOffset=0}, 
		Twitch = {projSpeed = 2.5, yOffset=-30}, 
		Udyr = {projSpeed = 0.467, yOffset=12}, 
		Urgot = {projSpeed = 1.3, yOffset=0}, 
		Varus = {projSpeed = 2.0, yOffset=0}, 
		Vayne = {projSpeed = 2.0, yOffset=12}, 
		Veigar = {projSpeed = 1.1, yOffset=0}, 
		Velkoz = {projSpeed = 2.0, yOffset=0}, 
		Vi = {projSpeed = 1.0, yOffset=0}, 0, 
		Viktor = {projSpeed = 2.3, yOffset=0}, 
		Vladimir = {projSpeed = 1.4, yOffset=0}, 
		Volibear = {projSpeed = 0.467, yOffset=0}, 
		Warwick = {projSpeed = 0, yOffset=18}, 
		Xerath = {projSpeed = 1.2, yOffset=0}, 
		XinZhao = {projSpeed = 0.02, yOffset=19}, 
		Yasuo = {projSpeed = 0.348, yOffset=0}, 
		Yorick = {projSpeed = 0, yOffset=0}, 
		Zac = {projSpeed = 1.0, yOffset=0}, 
		Zed = {projSpeed = 0.467, yOffset=0}, 
		Ziggs = {projSpeed = 1.5, yOffset=0}, 
		Zilean = {projSpeed = 1.2, yOffset=0}, 
		Zyra = {projSpeed = 1.7, yOffset=0}, 
		MalzaharVoidling = {projSpeed = 0}, 
		Blue_Minion_Basic = {projSpeed = 0, yOffset=0}, 
		Blue_Minion_Wizard = {projSpeed = 0.65, yOffset=0}, 
		Blue_Minion_MechCannon = {projSpeed = 1.2, yOffset=0}, 
		Blue_Minion_MechMelee = {projSpeed = 0, yOffset=0}, 
		Red_Minion_Basic = {projSpeed = 0, yOffset=0}, 
		Red_Minion_Wizard = {projSpeed = 0.65, yOffset=0}, 
		Red_Minion_MechCannon = {projSpeed = 1.2, yOffset=0}, 
		Red_Minion_MechMelee = {projSpeed = 0, yOffset=0}, 
		OrderTurretNormal = {projSpeed = 1.2, yOffset=0}, 
		OrderTurretNormal2 = {projSpeed = 1.2, yOffset=0}, 
		OrderTurretDragon = {projSpeed = 1.2, yOffset=0}, 
		OrderTurretAngel = {projSpeed = 1.2, yOffset=0}, 
		ChaosTurretWorm = {projSpeed = 1.2, yOffset=0}, 
		ChaosTurretWorm2 = {projSpeed = 1.2, yOffset=0}, 
		ChaosTurretGiant = {projSpeed = 1.2, yOffset=0}, 
		ChaosTurretNormal = {projSpeed = 1.2, yOffset=0}
	}
end
local tumbleExploit = {
	{startPos=Vector(11590.95, 51.98, 4656.26), endPos=Vector(11334.74, -62.83, 4517.47)},  -- bot
	{startPos=Vector(6639, 56.01, 8653), endPos=Vector(6364.96, -65.07, 8508.06)} -- mid
}
--[ End of Data ]--
local enemyHeroes = GetEnemyHeroes()
local projSpeed = champTable()[myHero.charName].projSpeed

--[ Globals ]--
local lastAttack = 0
local windUpTime = 0
local attackCooldown = 0
local targetArray = {}
local wayPointManager = WayPointManager()

--[ Functions ]--
function getTick()
	return GetGameTimer() * 1000
end
function getLatency()
	return GetLatency() / 2
end
function timeToShoot()
	return (getTick() + getLatency() > lastAttack + attackCooldown)
end
function heroCanMove()
	return (getTick() + getLatency() > lastAttack + windUpTime + 50)
end
function getTrueRange()
	return myHero.range + GetDistance(myHero.minBBox)
end
function Cleanup()
	for i, object in ipairs(targetArray) do
		if not object.valid or object.dead then
			table.remove(targetArray, i)
			i=i-1
		end
		if object.team ~= myHero.team and object.incomingDamage ~= nil then
			for k, cache in ipairs(object.incomingDamage) do
				if getTick() > cache.fin or cache.src.dead then
					table.remove(object.incomingDamage, k)
					k=k-1
				end
			end
		end
	end
	table.sort(targetArray, function(a, b) return a.incomingDamage and not b.incomingDamage end)
end
function calcDamage(src, dst, add)
	local armorPenPercent = src.armorPenPercent
	local armorPen = src.armorPen
	local totalDamage = src.totalDamage+(add or 0)
	local damageMultiplier = 0

	if src.charName == "Vayne" then
		if myHero:GetSpellData(_Q).level > 0 and myHero:CanUseSpell(_Q) == SUPRESSED then
			totalDamage = totalDamage+(myHero.totalDamage/100)*(myHero:GetSpellData(_Q).level*5+25)
		end
		if VayneWParticle and VayneWParticle.valid and GetDistance(VayneWParticle, dst) < 10 then
			totalDamage = totalDamage+((dst.maxHealth/100)*(myHero:GetSpellData(_W).level+3))+(10+(10*myHero:GetSpellData(_W).level))
		end
	end
	
	if src.type == "obj_AI_Minion" then
		armorPenPercent = 1
	elseif src.type == "obj_AI_Turret" then
		armorPenPercent = 0.7
	end
	
	local targetArmor = (dst.armor*armorPenPercent)-armorPen
	if targetArmor < 0 then
		damageMultiplier = 1*damageMultiplier
	else
		damageMultiplier = 100/(100+targetArmor)
	end
	
	return damageMultiplier * totalDamage
end

function canCondemn(pos, enemy, timeDelay)
	local predictPos = enemy
	if VIP_USER then
		local result, fTime = wayPointManager:GetSimulatedWayPoints(enemy)
		if #result ~= 1 then
			local wayPoint = Vector(result[2].x, enemy.y, result[2].y)
			local delay = GetDistance(myHero, enemy)/1200
			local predictPos = enemy+(wayPoint-enemy):normalized()*(enemy.ms*delay+(timeDelay or 0))
		end
	end
	for k=1, 390, 65 do -- 450 is max push distance
		if enemy.x > 0 and enemy.z > 0 then
			local pushPos = predictPos+(Vector(predictPos)-pos):normalized()*k
			if IsWall(D3DXVECTOR3(pushPos.x, pushPos.y, pushPos.z)) then
				return true
			end
		end
	end
	return false
end
function getPredictedHealth(minion, delay)
	local totalDamage = 0
	if minion.incomingDamage then
		for _, cache in pairs(minion.incomingDamage) do
			if delay > cache.fin then
				totalDamage = totalDamage+cache.dmg
			end
		end
	end
	return minion.health-totalDamage
end

--[ Callbacks ]--
function OnLoad()
	GRVayne = scriptConfig("GameRAT: Vayne", "GRVayne")
	GRVayne:addParam("active", "Custom", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("A"))
	GRVayne:addParam("laneClear", "Lane Clear", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
	
	GRVayne:addParam("drawCondemn", "Draw Condemn", SCRIPT_PARAM_ONOFF, false)
	GRVayne:addParam("priority", "Prioritize minions over harass", SCRIPT_PARAM_ONOFF, true)
	GRVayne:addParam("tumbleExploit", "Tumble Over Walls", SCRIPT_PARAM_ONOFF, true)
	GRVayne:addParam("debug", "Debug", SCRIPT_PARAM_ONOFF, false)
	
	PrintChat("GameRAT: Vayne")
end

function OnProcessSpell(object, spellProc)
	if object.isMe then
		local spellName = string.lower(spellProc.name)
		if spellName:find("attack") then
			lastAttack = getTick()-getLatency()
			windUpTime = spellProc.windUpTime*1000
			attackCooldown = spellProc.animationTime*1000
			
			if spellProc.target.type == "obj_AI_Hero" then DelayAction(function() CastSpell(_Q, mousePos.x, mousePos.z) end, spellProc.windUpTime) end
		elseif spellName:find("tumble") or spellName:find("condemn") then
			attackCooldown = 0
			lastAttack = 0
		end
	elseif object.type:find("obj_AI_") and object.team == myHero.team then
		for i, minion in pairs(targetArray) do
			if GetDistance(targetArray[i], spellProc.endPos) < 5 then
				if champTable()[object.charName] == nil then if self.debug then PrintChat("projSpeed not found [" .. object.charName .. "]") end return end -- error report
				if champTable()[object.charName].projSpeed == 0 then return end
				local tmp = {
					dmg=calcDamage(object, minion), 
					fin=getTick()+(spellProc.windUpTime*1000)+(GetDistance(object, minion)/champTable()[object.charName].projSpeed)-getLatency(), 
					src=object
				}
				minion.incomingDamage={}
				table.insert(minion.incomingDamage, tmp)
				return
			end
		end
	end
end

function OnCreateObj(object)
	if object ~= nil and object.type == "obj_AI_Minion" then
		for i, minion in pairs(targetArray) do
			if minion.health > object.health then
				table.insert(targetArray, i-1, object)
				return
			end
		end
		table.insert(targetArray, object)
	end
	
	if GetDistance(myHero, object) < 1000 and object.name:lower():find("vayne_w_ring2.troy") then
		VayneWParticle = object
	end
end

function autoCombo_OnTick()
	local QREADY = myHero:CanUseSpell(_Q) == READY
	local EREADY = myHero:CanUseSpell(_E) == READY
	
	if not QREADY and not EREADY then return false end
	
	for _, enemy in pairs(enemyHeroes) do
		if ValidTarget(enemy) then
			if EREADY and myHero.mana > 90 then -- Auto Condemn
				if GetDistance(myHero, enemy) < 715 and canCondemn(myHero, enemy) then
					CastSpell(_E, enemy)
					return true
				elseif QREADY and myHero.mana > 120 then -- Tumble then condemn
					local tumblePos = myHero+(Vector(enemy)-myHero):normalized()*300
					if GetDistance(tumblePos, enemy) < 715 and canCondemn(tumblePos, enemy) then
						CastSpell(_Q, tumblePos.x, tumblePos.z)
						return true
					end
				end
			end
			
			if QREADY and myHero.mana > 30 then
				local bonusDamage = (myHero.totalDamage/100)*(myHero:GetSpellData(_Q).level*5+25)
				local tumblePos = myHero+(Vector(enemy)-myHero):normalized()*300
				if GetDistance(tumblePos, enemy) < getTrueRange() and GetDistance(myHero, enemy) > getTrueRange() and calcDamage(myHero, enemy, bonusDamage) >= enemy.health then
					CastSpell(_Q, tumblePos.x, tumblePos.z)
					return true
				end
			end
		end
	end
	return false
end

function autoHarass_OnTick()
	local targetHero = {difficulty=math.huge}
	for _, enemy in ipairs(enemyHeroes) do
		local difficulty = (100/(100+enemy.armor)*enemy.health)/calcDamage(myHero, enemy)
		if ValidTarget(enemy, getTrueRange()) then
			if calcDamage(myHero, enemy) >= enemy.health then
				targetHero = enemy
				targetHero.difficulty = difficulty
				break
			elseif VayneWParticle and VayneWParticle.valid and GetDistance(VayneWParticle, enemy) < 10 then
				targetHero = enemy
				targetHero.difficulty = difficulty
				break
			elseif difficulty < targetHero.difficulty then
				targetHero = enemy
				targetHero.difficulty = difficulty
			end
		end
	end
	if targetHero.difficulty ~= math.huge then
		lastAttack = getTick()+getLatency()
		if VIP_USER then
			Packet('S_MOVE', {type=3, targetNetworkId=targetHero.networkID}):send()
		else
			myHero:Attack(targetHero)
		end
		return true
	end
	return false
end

function lastHit_OnTick()
	for i, minion in ipairs(targetArray) do
		local delay = getTick()+windUpTime+(GetDistance(myHero, minion)/projSpeed)+getLatency()
		if ValidTarget(minion, getTrueRange()) and myHero.team ~= minion.team then
			local totalDamage = 0
			if minion.incomingDamage ~= nil then
				for _, cache in pairs(minion.incomingDamage) do
					if delay > cache.fin then
						totalDamage = totalDamage+cache.dmg
					end
				end
			end
			if totalDamage < minion.health and calcDamage(myHero, minion)+totalDamage-2 > minion.health then
				lastAttack = getTick()+getLatency()
				if VIP_USER then
					Packet('S_MOVE', {type=3, targetNetworkId=minion.networkID}):send()
				else
					myHero:Attack(minion)
				end
				return true
			end
		end
	end
	return false
end

function laneClear_OnTick()
	local targetMinion = nil
	for _, minion in ipairs(targetArray) do
		local delay = getTick()+windUpTime+(GetDistance(myHero, minion)/projSpeed)+getLatency()
		if ValidTarget(minion, getTrueRange()) then
			if getPredictedHealth(minion, delay*2) < calcDamage(myHero, minion) then
				return false
			else
				targetMinion = minion
			end
		end
	end
	if targetMinion ~= nil then
		lastAttack = getTick()+getLatency()
		if VIP_USER then
			Packet('S_MOVE', {type=3, targetNetworkId=targetMinion.networkID}):send()
		else
			myHero:Attack(minion)
		end
		return true
	end
	return false
end

function OnTick()
	Cleanup()

	if GRVayne.active then autoCombo_OnTick() end
	if timeToShoot() then
		if GRVayne.priority then
			if GRVayne.active and (lastHit_OnTick() or autoHarass_OnTick()) then return end
		else
			if GRVayne.active and (autoHarass_OnTick() or lastHit_OnTick()) then return end
		end
		if GRVayne.laneClear and (lastHit_OnTick() or laneClear_OnTick()) then return
		end
	end
	if not _G.evade and heroCanMove() and GetDistance(myHero, mousePos) > 100 and (GRVayne.active or GRVayne.laneClear) then
		--tumble exploit
		if GRVayne.tumbleExploit then
			for _, exploit in pairs(tumbleExploit) do
				local midpoint = Vector((exploit.startPos.x+exploit.endPos.x)/2, (exploit.startPos.y+exploit.endPos.y)/2, (exploit.startPos.z+exploit.endPos.z)/2)
				if GetDistance(mousePos, midpoint) < 300  and myHero:CanUseSpell(_Q) == READY then
					if GetDistance(myHero, exploit.startPos) < 20 then
						CastSpell(_Q, exploit.endPos.x, exploit.endPos.z)
						return
					else
						if VIP_USER then
							Packet('S_MOVE', {type=2, x=exploit.startPos.x, y=exploit.startPos.z}):send()
						else
							myHero:MoveTo(exploit.startPos.x, exploit.startPos.z)
						end
						return
					end
				end
			end
		end
		if VIP_USER then
			Packet('S_MOVE', {type=2, x=mousePos.x, y=mousePos.z}):send()
		else
			myHero:MoveTo(mousePos.x, mousePos.z)
		end
	end
end

function OnDraw()
	if GRVayne.debug then
		-- Target Selector Debug
		for i, enemy in pairs(enemyHeroes) do
			DrawText(enemy.charName .. ": " .. math.round((100/(100+enemy.armor)*enemy.health)/calcDamage(myHero, enemy), 1), 16, 10, 10+(i*16), ARGB(255, 255, 255, 255))
		end
	end

	if GRVayne.tumbleExploit then
		for _, exploit in pairs(tumbleExploit) do
			DrawCircle(exploit.startPos.x, exploit.startPos.y, exploit.startPos.z, 10, ARGB(255,255,255,255))
			DrawCircle(exploit.endPos.x, exploit.endPos.y, exploit.endPos.z, 10, ARGB(255,255,255,255))
			DrawLine3D(exploit.startPos.x, exploit.startPos.y, exploit.startPos.z, exploit.endPos.x, exploit.endPos.y, exploit.endPos.z, 1, ARGB(255,255,255,255))
		end
	end

	DrawCircle(myHero.x, myHero.y, myHero.z, getTrueRange(), ARGB(255, 255, 255, 255))

	for i, minion in ipairs(targetArray) do
		if ValidTarget(minion, getTrueRange()) and myHero.team ~= minion.team then
			if calcDamage(myHero, minion) > minion.health then
				DrawCircle(minion.x, minion.y, minion.z, 100, ARGB(255, 255, 0, 255))
			end
		end
	end

	if GRVayne.drawCondemn then
		for _, enemy in pairs(enemyHeroes) do
			if ValidTarget(enemy, 2000) then
				local predictPos = enemy
				if VIP_USER then
					local result, fTime = wayPointManager:GetSimulatedWayPoints(enemy)
					if #result ~= 1 then
						local wayPoint = Vector(result[2].x, enemy.y, result[2].y)
						local delay = GetDistance(myHero, enemy)/1.2
						local predictPos = enemy+(wayPoint-enemy):normalized()*(enemy.ms*delay)
					end
				end
				if enemy.x > 0 and enemy.z > 0 then
					local pushPos = predictPos+(Vector(predictPos)-myHero):normalized()*390
					DrawCircle(pushPos.x, pushPos.y, pushPos.z, 50, ARGB(255, 255, 255, 255))
				end
			end
		end
	end
end
