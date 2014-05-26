--[[ 
	GameRAT: Vayne
		rev. 14524
	
	What needs to be done?
	-Insert minions into table upon loading script.
	-Auto-condemn gap closers.
	-Smart Q [WIP]
	-Issue with calcDamage function, this appears to have something to do with armor penetration/ghostblade
	-Stop attacking objects if mousePos and myHero are near tumbleExploit
	-Add more menu options. More customization.
	-Avoid tumbling in bad situations
	-Cancel auto condemn if not going to be stunned [Done but not confirmed]
]]--

if VIP_USER and FileExist(LIB_PATH .. "/Selector.lua") then
	require "Selector"
	local USE_SELECTOR = true
end
if myHero.charName ~= "Vayne" then return end

--[ UPDATE ]--
local local_version = 14524
local server_version = tonumber(GetWebResult("raw.github.com", "/Jo7j/BoL/master/version/GRVayne.version"))
if server_version > local_version then
	PrintChat("Script is outdated. Updating to version: " .. server_version .. "...")
	DownloadFile("https://raw.github.com/Jo7j/BoL/master/GRVayne.lua", SCRIPT_PATH .. "GRVayne.lua", function()
            PrintChat("Script updated. Please reload (F9).")
        end)
end
--[ END OF UPDATE ]--

--[ DATA ]--
function champTable()
	return { 
		Aatrox = {projSpeed = 0.348},Ahri = {projSpeed = 1.75},Akali = {projSpeed = 0.467},Alistar = {projSpeed = 0},Amumu = {projSpeed = 0.5},Anivia = {projSpeed = 1.4},Annie = {projSpeed = 1.2},Ashe = {projSpeed = 2.0},Blitzcrank = {projSpeed = 0},Brand = {projSpeed = 2.0},Braum = {projSpeed = 0},Caitlyn = {projSpeed = 2.5},Cassiopeia = {projSpeed = 1.2},Chogath = {projSpeed = 0.5},Corki = {projSpeed = 2.0},Darius = {projSpeed = 0},Diana = {projSpeed = 0.348},DrMundo = {projSpeed = 0},Draven = {projSpeed = 1.7},Elise = {projSpeed = 1.6},Evelynn = {projSpeed = 0.467},Ezreal = {projSpeed = 2.0},FiddleSticks = {projSpeed = 1.75},Fiora = {projSpeed = 0.467},Fizz = {projSpeed = 0},Galio = {projSpeed = 1.0},Gangplank = {projSpeed = 1.0},Garen = {projSpeed = 0.348},Gragas = {projSpeed = 0},Graves = {projSpeed = 3.0},Hecarim = {projSpeed = 0.5},Heimerdinger = {projSpeed = 1.5},Irelia = {projSpeed = 0.467},Janna = {projSpeed = 1.2},JarvanIV = {projSpeed = 0.02},Jax = {projSpeed = 0.4},Jayce = {projSpeed = 0.348},Jinx = {projSpeed = 2.75},Karma = {projSpeed = 1.5},Karthus = {projSpeed = 1.2},Kassadin = {projSpeed = 0},Katarina = {projSpeed = 0.467},Kayle = {projSpeed = 1.8},Kennen = {projSpeed = 1.6},Khazix = {projSpeed = 0.5},KogMaw = {projSpeed = 1.8},Leblanc = {projSpeed = 1.7},LeeSin = {projSpeed = 0},Leona = {projSpeed = 0.348},Lissandra = {projSpeed = 2.0},Lucian = {projSpeed = 2.8},Lulu = {projSpeed = 1.45},Lux = {projSpeed = 1.6},Malphite = {projSpeed = 1.0},Malzahar = {projSpeed = 2.0},Maokai = {projSpeed = 0},MasterYi = {projSpeed = 0},MissFortune = {projSpeed = 2.0},Mordekaiser = {projSpeed = 0},Morgana = {projSpeed = 1.6},MonkeyKing = {projSpeed = 0.02},Nami = {projSpeed = 1.5},Nasus = {projSpeed = 0},Nautilus = {projSpeed = 1.0},Nidalee = {projSpeed = 1.75},Nocturne = {projSpeed = 0},Nunu = {projSpeed = 0.5},Olaf = {projSpeed = 0.348},Orianna = {projSpeed = 1.45},Pantheon = {projSpeed = 0.02},Poppy = {projSpeed = 0.5},Quinn = {projSpeed = 2.0},Rammus = {projSpeed = 0},Renekton = {projSpeed = 0},Rengar = {projSpeed = 0},Riven = {projSpeed = 0.348},Rumble = {projSpeed = 0.348},Ryze = {projSpeed = 2.4},Sejuani = {projSpeed = 0.5},Shaco = {projSpeed = 0},Shen = {projSpeed = 0.4},Shyvana = {projSpeed = 0},Singed = {projSpeed = 0.7},Sion = {projSpeed = 0},Sivir = {projSpeed = 1.75},Skarner = {projSpeed = 0.5},Sona = {projSpeed = 1.5},Soraka = {projSpeed = 1.0},Swain = {projSpeed = 1.6},Syndra = {projSpeed = 1.8},Talon = {projSpeed = 0},Taric = {projSpeed = 0},Teemo = {projSpeed = 1.3},Thresh = {projSpeed = 0},Tristana = {projSpeed = 2.25},Trundle = {projSpeed = 0.348},Tryndamere = {projSpeed = 0.348},TwistedFate = {projSpeed = 1.5},Twitch = {projSpeed = 2.5},Udyr = {projSpeed = 0.467},Urgot = {projSpeed = 1.3},Varus = {projSpeed = 2.0},Vayne = {projSpeed = 2.0},Veigar = {projSpeed = 1.1},Velkoz = {projSpeed = 2.0},Vi = {projSpeed = 1.0}, Viktor = {projSpeed = 2.3},Vladimir = {projSpeed = 1.4},Volibear = {projSpeed = 0.467},Warwick = {projSpeed = 0},Xerath = {projSpeed = 1.2},XinZhao = {projSpeed = 0.02},Yasuo = {projSpeed = 0.348},Yorick = {projSpeed = 0},Zac = {projSpeed = 1.0},Zed = {projSpeed = 0.467},Ziggs = {projSpeed = 1.5},Zilean = {projSpeed = 1.2},Zyra = {projSpeed = 1.7},MalzaharVoidling = {projSpeed = 0},Blue_Minion_Basic = {projSpeed = 0},Blue_Minion_Wizard = {projSpeed = 0.65},Blue_Minion_MechCannon = {projSpeed = 1.2},Blue_Minion_MechMelee = {projSpeed = 0},Red_Minion_Basic = {projSpeed = 0},Red_Minion_Wizard = {projSpeed = 0.65},Red_Minion_MechCannon = {projSpeed = 1.2},Red_Minion_MechMelee = {projSpeed = 0},OrderTurretNormal = {projSpeed = 1.2},OrderTurretNormal2 = {projSpeed = 1.2},OrderTurretDragon = {projSpeed = 1.2},OrderTurretAngel = {projSpeed = 1.2},ChaosTurretWorm = {projSpeed = 1.2},ChaosTurretWorm2 = {projSpeed = 1.2},ChaosTurretGiant = {projSpeed = 1.2},ChaosTurretNormal = {projSpeed = 1.2}
	}
end
local tumbleExploit = {
	{startPos=Vector(11590.95, 51.98, 4656.26), endPos=Vector(11334.74, -62.83, 4517.47)},  -- bot
	{startPos=Vector(6639, 56.01, 8653), endPos=Vector(6364.96, -65.07, 8508.06)} -- mid
}
local skillshotsToAvoid = {
	["CaitlynPiltoverPeacemaker"] = {projSpeed = 2200, radius = 90}, 
}
--[ End of Data ]--
local enemyHeroes = GetEnemyHeroes()
local projSpeed = champTable()[myHero.charName].projSpeed

--[ Globals ]--
local lastAttack = 0
local windUpTime = 0
local attackCooldown = 0
local targetArray = {}
local tp = VIP_USER and TargetPredictionVIP(715, 1200, 0.25) or TargetPrediction(715, 1200, 0.25)
local tp = VIP_USER and TargetPredictionVIP(715, 1200, 0.25) or TargetPrediction(715, 1200, 0.25)

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
		if VayneWRing2 and VayneWRing2.valid and GetDistance(VayneWRing2, dst) < 10 then
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

function canCondemn(pos, enemy)
	local predictPos = tp:GetPrediction(enemy) or enemy
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

function isFacing(source, target, lineLength)
	local sourceVector = Vector(source.visionPos.x, source.visionPos.z)
	local sourcePos = Vector(source.x, source.z)
	sourceVector = (sourceVector-sourcePos):normalized()
	sourceVector = sourcePos + (sourceVector*(GetDistance(target, source)))
	return GetDistanceSqr(target, {x = sourceVector.x, z = sourceVector.y}) <= (lineLength and lineLength^2 or 90000)
end

function smartQ(enemy)
	--Later, when I have time, this function will return false if certain enemy spells are not on cooldown such as RocketGrab
	local distance = GetDistance(myHero, enemy)
	
	if enemy and enemy.type == "obj_AI_Hero" and distance < getTrueRange()+300 and enemy.health > calcDamage(myHero, enemy) then
		local tumblePos = mousePos
		if GRVayne.smartQ then
			if distance < getTrueRange() and isFacing(enemy, myHero) and distance < GetDistance(mousePos, enemy) then -- kiting
				tumblePos = myHero+(Vector(enemy)-myHero):normalized()*-300
			elseif GetDistance(mousePos, enemy) < 200 and isFacing(myHero, enemy) and not isFacing(enemy, myHero) then -- chasing
				tumblePos = myHero+(Vector(enemy)-myHero):normalized()*300
			else
				local angle = math.acos( (distance^2 + 300^2 - getTrueRange()^2) / (2 * distance * 300) )
				--PrintChat("deg: " .. math.deg(angle))
				tumblePos = Vector(myHero.x+(math.cos(angle)*300), myHero.y, myHero.z+(math.sin(angle)*300))
			end

		end
		CastSpell(_Q, tumblePos.x, tumblePos.z)
	end
	return false
end

function findTarget(method, range)
	local result = nil
	if method == 0 then --LOWEST
		local LOWEST = math.huge
		for _, enemy in pairs(enemyHeroes) do
			if GetDistance(myHero, enemy) < range then
				local difficulty = (100/(100+enemy.armor)*enemy.health)/calcDamage(myHero, enemy)
				if difficulty < LOWEST then
					LOWEST = difficulty
					result = enemy
				end
			end
		end
	elseif method == 1 then --MOST_DANGEROUS
		local MOST_DANGEROUS = math.huge
		for _, enemy in pairs(enemyHeroes) do
			if GetDistance(myHero, enemy) < range then
				local capability = (enemy.totalDamage*enemy.attackSpeed)*enemy.armorPenPercent
				if enemy.ap > enemy.totalDamage then
					local manaCost = 0
					local spells = {_Q, _W, _E, _R}
					for k, spell in pairs(spells) do
						if enemy:CanUseSpell(spell) == READY then
							manaCost = manaCost+enemy:GetSpellData(spell).mana
						end
					end
					local capability = (enemy.ap*(enemy.mana/manaCost))*enemy.magicPenPercent
				end
				if capability > MOST_DANGEROUS then
					MOST_DANGEROUS = capability
					result = enemy
				end
			end
		end
	end
	return result
end

--[ Callbacks ]--
function OnLoad()
	GRVayne = scriptConfig("GameRAT: Vayne", "GRVayne")
	GRVayne:addParam("active", "Custom", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("A"))
	GRVayne:addParam("laneClear", "Lane Clear", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
	
	GRVayne:addParam("drawCondemn", "Draw Condemn", SCRIPT_PARAM_ONOFF, false)
	GRVayne:addParam("priority", "Prioritize minions over harass", SCRIPT_PARAM_ONOFF, true)
	GRVayne:addParam("tumbleExploit", "Tumble Over Walls", SCRIPT_PARAM_ONOFF, true)
	GRVayne:addParam("smartQ", "Smart Q", SCRIPT_PARAM_ONOFF, false)
	GRVayne:addParam("debug", "Debug", SCRIPT_PARAM_ONOFF, false)
	
	if USE_SELECTOR then
		Selector.Instance()
	end
	
	PrintChat("GameRAT: Vayne")
end

function OnProcessSpell(object, spellProc)
	if object.isMe then
		local spellName = string.lower(spellProc.name)
		if spellName:find("attack") then
			lastAttack = getTick()-getLatency()
			windUpTime = spellProc.windUpTime*1000
			attackCooldown = spellProc.animationTime*1000
			
			DelayAction(function()
				smartQ(spellProc.target)
			end, spellProc.windUpTime)
			
		elseif spellName:find("tumble") then
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
	if object ~= nil and object.type == "obj_AI_Minion" and object.name:find("Minion") then
		for i, minion in pairs(targetArray) do
			if minion.health > object.health then
				table.insert(targetArray, i-1, object)
				--PrintChat(object.name)
				return
			end
		end
		table.insert(targetArray, object)
	end
	
	if GetDistance(myHero, object) < 1000 and object.name:lower():find("vayne_w_ring2.troy") then
		VayneWRing2 = object
	end
end

function autoCombo_OnTick()
	local QREADY = myHero:CanUseSpell(_Q) == READY
	local EREADY = myHero:CanUseSpell(_E) == READY
	
	if not QREADY and not EREADY then return false end
	
	local enemy = USE_SELECTOR and Selector.GetTarget(MOST_DANGEROUS_ADVANCED, 715) or findTarget(1, 715)
	if enemy then
			if EREADY and myHero.mana > 90 then -- Auto Condemn
				if GetDistance(myHero, enemy) < 715 and canCondemn(myHero, enemy) then
					CastSpell(_E, enemy)
					return true
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

function autoHarass_OnTick()
	local enemy = USE_SELECTOR and Selector.GetTarget(LOWEST, getTrueRange()) or findTarget(0, getTrueRange())
	if enemy then
		lastAttack = getTick()+getLatency()
		if VIP_USER then
			Packet('S_MOVE', {type=3, targetNetworkId=enemy.networkID}):send()
		else
			myHero:Attack(enemy)
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
			if calcDamage(myHero, minion) > getPredictedHealth(minion, delay) then
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
		for _, enemy in pairs(enemyHeroes) do
			local distance = GetDistance(myHero, enemy)
			if ValidTarget(enemy, getTrueRange()+300) then
				local tumblePos = myHero+(Vector(enemy)-myHero)
				if distance < getTrueRange() and isFacing(enemy, myHero) then -- kiting
					tumblePos = tumblePos:normalized()*-300
				elseif GetDistance(mousePos, enemy) < 200 and isFacing(myHero, enemy) and not isFacing(enemy, myHero) then -- chasing
					tumblePos = tumblePos:normalized()*300
				else
					local angle = math.acos( (distance^2 + 300^2 - getTrueRange()^2) / (2 * distance * 300) )
					--PrintChat("deg: " .. math.deg(angle))
					tumblePos = Vector(myHero.x+(math.cos(angle)*300), myHero.y, myHero.z+(math.sin(angle)*300))
				end
				DrawCircle(tumblePos.x, tumblePos.y, tumblePos.z, 50, ARGB(255, 255, 255, 255))
			end
		end
	end

	if GRVayne.tumbleExploit then
		for _, exploit in pairs(tumbleExploit) do
			DrawCircle(exploit.startPos.x, exploit.startPos.y, exploit.startPos.z, 10, ARGB(255,255,255,255))
			DrawCircle(exploit.endPos.x, exploit.endPos.y, exploit.endPos.z, 10, ARGB(255,255,255,255))
			DrawLine3D(exploit.startPos.x, exploit.startPos.y, exploit.startPos.z, exploit.endPos.x, exploit.endPos.y, exploit.endPos.z, 1, ARGB(255,255,255,255))
			if GRVayne.debug then DrawLine3D(exploit.startPos.x, exploit.startPos.y, exploit.startPos.z, exploit.startPos.x, exploit.startPos.y, exploit.startPos.z-GetDistance(exploit.startPos, exploit.endPos), 1, ARGB(255,255,255,255)) end
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
end
