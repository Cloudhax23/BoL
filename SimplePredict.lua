--[[
	SimplePredict alpha
		a lightweight prediction library
	
	SP = SimplePredict()
	
	Methods:
		local isAttacking = SimplePredict:IsAttacking(unit)
		local isTooSlow = SimplePredict:IsTooSlow(unit, time, radius)
		local hitChance = SimplePredict:GetHitChance(unit, radius, delay)
		local collision = SimplePredict:CheckCollision(startPos, endPos, speed, delay, radius, colTable)
		local obstacles = SimplePredict:GetCollision(startPos, endPos, speed, delay, radius, colTable)
		local predictPos = SimplePredict:GetIdlePrediction(unit, radius)
		local predictPos = SimplePredict:GetPredictedPosition(unit, delay, radius)
		local predictPos, maxTargets = SimplePredict:GetAOEPredictedPosition(unit, delay, radius)
		local predictHp = SimplePredict:GetPredictedHealth(unit, delay)
	
	Hit Chance:
		0 - Unit is not moving
		1 - Unit is moving
		2 - Unit is attacking/channelling
		3 - Unit is too slow (~100%)
		4 - Unit is immobile (~100%)
		5 - Unit is dashing/blinking (~100%)
	
	Thanks to Honda7 for his VPrediction library
]]

projectilespeeds = {["Velkoz"]= 2000,["TeemoMushroom"] = math.huge,["TestCubeRender"] = math.huge ,["Xerath"] = 2000.0000 ,["Kassadin"] = math.huge ,["Rengar"] = math.huge ,["Thresh"] = 1000.0000 ,["Ziggs"] = 1500.0000 ,["ZyraPassive"] = 1500.0000 ,["ZyraThornPlant"] = 1500.0000 ,["KogMaw"] = 1800.0000 ,["HeimerTBlue"] = 1599.3999 ,["EliseSpider"] = 500.0000 ,["Skarner"] = 500.0000 ,["ChaosNexus"] = 500.0000 ,["Katarina"] = 467.0000 ,["Riven"] = 347.79999 ,["SightWard"] = 347.79999 ,["HeimerTYellow"] = 1599.3999 ,["Ashe"] = 2000.0000 ,["VisionWard"] = 2000.0000 ,["TT_NGolem2"] = math.huge ,["ThreshLantern"] = math.huge ,["TT_Spiderboss"] = math.huge ,["OrderNexus"] = math.huge ,["Soraka"] = 1000.0000 ,["Jinx"] = 2750.0000 ,["TestCubeRenderwCollision"] = 2750.0000 ,["Red_Minion_Wizard"] = 650.0000 ,["JarvanIV"] = 20.0000 ,["Blue_Minion_Wizard"] = 650.0000 ,["TT_ChaosTurret2"] = 1200.0000 ,["TT_ChaosTurret3"] = 1200.0000 ,["TT_ChaosTurret1"] = 1200.0000 ,["ChaosTurretGiant"] = 1200.0000 ,["Dragon"] = 1200.0000 ,["LuluSnowman"] = 1200.0000 ,["Worm"] = 1200.0000 ,["ChaosTurretWorm"] = 1200.0000 ,["TT_ChaosInhibitor"] = 1200.0000 ,["ChaosTurretNormal"] = 1200.0000 ,["AncientGolem"] = 500.0000 ,["ZyraGraspingPlant"] = 500.0000 ,["HA_AP_OrderTurret3"] = 1200.0000 ,["HA_AP_OrderTurret2"] = 1200.0000 ,["Tryndamere"] = 347.79999 ,["OrderTurretNormal2"] = 1200.0000 ,["Singed"] = 700.0000 ,["OrderInhibitor"] = 700.0000 ,["Diana"] = 347.79999 ,["HA_FB_HealthRelic"] = 347.79999 ,["TT_OrderInhibitor"] = 347.79999 ,["GreatWraith"] = 750.0000 ,["Yasuo"] = 347.79999 ,["OrderTurretDragon"] = 1200.0000 ,["OrderTurretNormal"] = 1200.0000 ,["LizardElder"] = 500.0000 ,["HA_AP_ChaosTurret"] = 1200.0000 ,["Ahri"] = 1750.0000 ,["Lulu"] = 1450.0000 ,["ChaosInhibitor"] = 1450.0000 ,["HA_AP_ChaosTurret3"] = 1200.0000 ,["HA_AP_ChaosTurret2"] = 1200.0000 ,["ChaosTurretWorm2"] = 1200.0000 ,["TT_OrderTurret1"] = 1200.0000 ,["TT_OrderTurret2"] = 1200.0000 ,["TT_OrderTurret3"] = 1200.0000 ,["LuluFaerie"] = 1200.0000 ,["HA_AP_OrderTurret"] = 1200.0000 ,["OrderTurretAngel"] = 1200.0000 ,["YellowTrinketUpgrade"] = 1200.0000 ,["MasterYi"] = math.huge ,["Lissandra"] = 2000.0000 ,["ARAMOrderTurretNexus"] = 1200.0000 ,["Draven"] = 1700.0000 ,["FiddleSticks"] = 1750.0000 ,["SmallGolem"] = math.huge ,["ARAMOrderTurretFront"] = 1200.0000 ,["ChaosTurretTutorial"] = 1200.0000 ,["NasusUlt"] = 1200.0000 ,["Maokai"] = math.huge ,["Wraith"] = 750.0000 ,["Wolf"] = math.huge ,["Sivir"] = 1750.0000 ,["Corki"] = 2000.0000 ,["Janna"] = 1200.0000 ,["Nasus"] = math.huge ,["Golem"] = math.huge ,["ARAMChaosTurretFront"] = 1200.0000 ,["ARAMOrderTurretInhib"] = 1200.0000 ,["LeeSin"] = math.huge ,["HA_AP_ChaosTurretTutorial"] = 1200.0000 ,["GiantWolf"] = math.huge ,["HA_AP_OrderTurretTutorial"] = 1200.0000 ,["YoungLizard"] = 750.0000 ,["Jax"] = 400.0000 ,["LesserWraith"] = math.huge ,["Blitzcrank"] = math.huge ,["ARAMChaosTurretInhib"] = 1200.0000 ,["Shen"] = 400.0000 ,["Nocturne"] = math.huge ,["Sona"] = 1500.0000 ,["ARAMChaosTurretNexus"] = 1200.0000 ,["YellowTrinket"] = 1200.0000 ,["OrderTurretTutorial"] = 1200.0000 ,["Caitlyn"] = 2500.0000 ,["Trundle"] = 347.79999 ,["Malphite"] = 1000.0000 ,["Mordekaiser"] = math.huge ,["ZyraSeed"] = math.huge ,["Vi"] = 1000.0000 ,["Tutorial_Red_Minion_Wizard"] = 650.0000 ,["Renekton"] = math.huge ,["Anivia"] = 1400.0000 ,["Fizz"] = math.huge ,["Heimerdinger"] = 1500.0000 ,["Evelynn"] = 467.0000 ,["Rumble"] = 347.79999 ,["Leblanc"] = 1700.0000 ,["Darius"] = math.huge ,["OlafAxe"] = math.huge ,["Viktor"] = 2300.0000 ,["XinZhao"] = 20.0000 ,["Orianna"] = 1450.0000 ,["Vladimir"] = 1400.0000 ,["Nidalee"] = 1750.0000 ,["Tutorial_Red_Minion_Basic"] = math.huge ,["ZedShadow"] = 467.0000 ,["Syndra"] = 1800.0000 ,["Zac"] = 1000.0000 ,["Olaf"] = 347.79999 ,["Veigar"] = 1100.0000 ,["Twitch"] = 2500.0000 ,["Alistar"] = math.huge ,["Akali"] = 467.0000 ,["Urgot"] = 1300.0000 ,["Leona"] = 347.79999 ,["Talon"] = math.huge ,["Karma"] = 1500.0000 ,["Jayce"] = 347.79999 ,["Galio"] = 1000.0000 ,["Shaco"] = math.huge ,["Taric"] = math.huge ,["TwistedFate"] = 1500.0000 ,["Varus"] = 2000.0000 ,["Garen"] = 347.79999 ,["Swain"] = 1600.0000 ,["Vayne"] = 2000.0000 ,["Fiora"] = 467.0000 ,["Quinn"] = 2000.0000 ,["Kayle"] = math.huge ,["Blue_Minion_Basic"] = math.huge ,["Brand"] = 2000.0000 ,["Teemo"] = 1300.0000 ,["Amumu"] = 500.0000 ,["Annie"] = 1200.0000 ,["Odin_Blue_Minion_caster"] = 1200.0000 ,["Elise"] = 1600.0000 ,["Nami"] = 1500.0000 ,["Poppy"] = 500.0000 ,["AniviaEgg"] = 500.0000 ,["Tristana"] = 2250.0000 ,["Graves"] = 3000.0000 ,["Morgana"] = 1600.0000 ,["Gragas"] = math.huge ,["MissFortune"] = 2000.0000 ,["Warwick"] = math.huge ,["Cassiopeia"] = 1200.0000 ,["Tutorial_Blue_Minion_Wizard"] = 650.0000 ,["DrMundo"] = math.huge ,["Volibear"] = 467.0000 ,["Irelia"] = 467.0000 ,["Odin_Red_Minion_Caster"] = 650.0000 ,["Lucian"] = 2800.0000 ,["Yorick"] = math.huge ,["RammusPB"] = math.huge ,["Red_Minion_Basic"] = math.huge ,["Udyr"] = 467.0000 ,["MonkeyKing"] = 20.0000 ,["Tutorial_Blue_Minion_Basic"] = math.huge ,["Kennen"] = 1600.0000 ,["Nunu"] = 500.0000 ,["Ryze"] = 2400.0000 ,["Zed"] = 467.0000 ,["Nautilus"] = 1000.0000 ,["Gangplank"] = 1000.0000 ,["Lux"] = 1600.0000 ,["Sejuani"] = 500.0000 ,["Ezreal"] = 2000.0000 ,["OdinNeutralGuardian"] = 1800.0000 ,["Khazix"] = 500.0000 ,["Sion"] = math.huge ,["Aatrox"] = 347.79999 ,["Hecarim"] = 500.0000 ,["Pantheon"] = 20.0000 ,["Shyvana"] = 467.0000 ,["Zyra"] = 1700.0000 ,["Karthus"] = 1200.0000 ,["Rammus"] = math.huge ,["Zilean"] = 1200.0000 ,["Chogath"] = 500.0000 ,["Malzahar"] = 2000.0000 ,["YorickRavenousGhoul"] = 347.79999 ,["YorickSpectralGhoul"] = 347.79999 ,["JinxMine"] = 347.79999 ,["YorickDecayedGhoul"] = 347.79999 ,["XerathArcaneBarrageLauncher"] = 347.79999 ,["Odin_SOG_Order_Crystal"] = 347.79999 ,["TestCube"] = 347.79999 ,["ShyvanaDragon"] = math.huge ,["FizzBait"] = math.huge ,["Blue_Minion_MechMelee"] = math.huge ,["OdinQuestBuff"] = math.huge ,["TT_Buffplat_L"] = math.huge ,["TT_Buffplat_R"] = math.huge ,["KogMawDead"] = math.huge ,["TempMovableChar"] = math.huge ,["Lizard"] = 500.0000 ,["GolemOdin"] = math.huge ,["OdinOpeningBarrier"] = math.huge ,["TT_ChaosTurret4"] = 500.0000 ,["TT_Flytrap_A"] = 500.0000 ,["TT_NWolf"] = math.huge ,["OdinShieldRelic"] = math.huge ,["LuluSquill"] = math.huge ,["redDragon"] = math.huge ,["MonkeyKingClone"] = math.huge ,["Odin_skeleton"] = math.huge ,["OdinChaosTurretShrine"] = 500.0000 ,["Cassiopeia_Death"] = 500.0000 ,["OdinCenterRelic"] = 500.0000 ,["OdinRedSuperminion"] = math.huge ,["JarvanIVWall"] = math.huge ,["ARAMOrderNexus"] = math.huge ,["Red_Minion_MechCannon"] = 1200.0000 ,["OdinBlueSuperminion"] = math.huge ,["SyndraOrbs"] = math.huge ,["LuluKitty"] = math.huge ,["SwainNoBird"] = math.huge ,["LuluLadybug"] = math.huge ,["CaitlynTrap"] = math.huge ,["TT_Shroom_A"] = math.huge ,["ARAMChaosTurretShrine"] = 500.0000 ,["Odin_Windmill_Propellers"] = 500.0000 ,["TT_NWolf2"] = math.huge ,["OdinMinionGraveyardPortal"] = math.huge ,["SwainBeam"] = math.huge ,["Summoner_Rider_Order"] = math.huge ,["TT_Relic"] = math.huge ,["odin_lifts_crystal"] = math.huge ,["OdinOrderTurretShrine"] = 500.0000 ,["SpellBook1"] = 500.0000 ,["Blue_Minion_MechCannon"] = 1200.0000 ,["TT_ChaosInhibitor_D"] = 1200.0000 ,["Odin_SoG_Chaos"] = 1200.0000 ,["TrundleWall"] = 1200.0000 ,["HA_AP_HealthRelic"] = 1200.0000 ,["OrderTurretShrine"] = 500.0000 ,["OriannaBall"] = 500.0000 ,["ChaosTurretShrine"] = 500.0000 ,["LuluCupcake"] = 500.0000 ,["HA_AP_ChaosTurretShrine"] = 500.0000 ,["TT_NWraith2"] = 750.0000 ,["TT_Tree_A"] = 750.0000 ,["SummonerBeacon"] = 750.0000 ,["Odin_Drill"] = 750.0000 ,["TT_NGolem"] = math.huge ,["AramSpeedShrine"] = math.huge ,["OriannaNoBall"] = math.huge ,["Odin_Minecart"] = math.huge ,["Summoner_Rider_Chaos"] = math.huge ,["OdinSpeedShrine"] = math.huge ,["TT_SpeedShrine"] = math.huge ,["odin_lifts_buckets"] = math.huge ,["OdinRockSaw"] = math.huge ,["OdinMinionSpawnPortal"] = math.huge ,["SyndraSphere"] = math.huge ,["Red_Minion_MechMelee"] = math.huge ,["SwainRaven"] = math.huge ,["crystal_platform"] = math.huge ,["MaokaiSproutling"] = math.huge ,["Urf"] = math.huge ,["TestCubeRender10Vision"] = math.huge ,["MalzaharVoidling"] = 500.0000 ,["GhostWard"] = 500.0000 ,["MonkeyKingFlying"] = 500.0000 ,["LuluPig"] = 500.0000 ,["AniviaIceBlock"] = 500.0000 ,["TT_OrderInhibitor_D"] = 500.0000 ,["Odin_SoG_Order"] = 500.0000 ,["RammusDBC"] = 500.0000 ,["FizzShark"] = 500.0000 ,["LuluDragon"] = 500.0000 ,["OdinTestCubeRender"] = 500.0000 ,["TT_Tree1"] = 500.0000 ,["ARAMOrderTurretShrine"] = 500.0000 ,["Odin_Windmill_Gears"] = 500.0000 ,["ARAMChaosNexus"] = 500.0000 ,["TT_NWraith"] = 750.0000 ,["TT_OrderTurret4"] = 500.0000 ,["Odin_SOG_Chaos_Crystal"] = 500.0000 ,["OdinQuestIndicator"] = 500.0000 ,["JarvanIVStandard"] = 500.0000 ,["TT_DummyPusher"] = 500.0000 ,["OdinClaw"] = 500.0000 ,["EliseSpiderling"] = 2000.0000 ,["QuinnValor"] = math.huge ,["UdyrTigerUlt"] = math.huge ,["UdyrTurtleUlt"] = math.huge ,["UdyrUlt"] = math.huge ,["UdyrPhoenixUlt"] = math.huge ,["ShacoBox"] = 1500.0000 ,["HA_AP_Poro"] = 1500.0000 ,["AnnieTibbers"] = math.huge ,["UdyrPhoenix"] = math.huge ,["UdyrTurtle"] = math.huge ,["UdyrTiger"] = math.huge ,["HA_AP_OrderShrineTurret"] = 500.0000 ,["HA_AP_Chains_Long"] = 500.0000 ,["HA_AP_BridgeLaneStatue"] = 500.0000 ,["HA_AP_ChaosTurretRubble"] = 500.0000 ,["HA_AP_PoroSpawner"] = 500.0000 ,["HA_AP_Cutaway"] = 500.0000 ,["HA_AP_Chains"] = 500.0000 ,["ChaosInhibitor_D"] = 500.0000 ,["ZacRebirthBloblet"] = 500.0000 ,["OrderInhibitor_D"] = 500.0000 ,["Nidalee_Spear"] = 500.0000 ,["Nidalee_Cougar"] = 500.0000 ,["TT_Buffplat_Chain"] = 500.0000 ,["WriggleLantern"] = 500.0000 ,["TwistedLizardElder"] = 500.0000 ,["RabidWolf"] = math.huge ,["HeimerTGreen"] = 1599.3999 ,["HeimerTRed"] = 1599.3999 ,["ViktorFF"] = 1599.3999 ,["TwistedGolem"] = math.huge ,["TwistedSmallWolf"] = math.huge ,["TwistedGiantWolf"] = math.huge ,["TwistedTinyWraith"] = 750.0000 ,["TwistedBlueWraith"] = 750.0000 ,["TwistedYoungLizard"] = 750.0000 ,["Red_Minion_Melee"] = math.huge ,["Blue_Minion_Melee"] = math.huge ,["Blue_Minion_Healer"] = 1000.0000 ,["Ghast"] = 750.0000 ,["blueDragon"] = 800.0000 ,["Red_Minion_MechRange"] = 3000.0000,}

class "SimplePredict"

function SimplePredict:__init()
	self.Config = scriptConfig("SimplePredict", "SimplePredict")
		self.Config:addSubMenu("Collision", "collision")
			self.Config.collision:addParam("predictPos", "Predict Obstacle Positions", SCRIPT_PARAM_ONOFF, true)
			--self.Config.collision:addParam("predictHp", "Predict Obstacle Health", SCRIPT_PARAM_ONOFF, false)
			self.Config.collision:addParam("extraBuffer", "Extra Collision Buffer", SCRIPT_PARAM_SLICE, 20, 0, 50, 0)
			
		self.Config:addParam("predictIdle", "Use Idle Prediction", SCRIPT_PARAM_ONOFF, true)
		self.Config:addParam("reactTime", "Player Reaction Time (ms)", SCRIPT_PARAM_SLICE, 215, 0, 500, 0)
		--self.Config:addParam("debug", "Debug Mode (Drawing)", SCRIPT_PARAM_ONOFF, false)
	
	self.heroes = {}
	for i = 1, heroManager.iCount do
		local hero = heroManager:GetHero(i)
		if hero.team == TEAM_ENEMY then -- Only insert enemies
			hero.idlePredict = Vector(0, 0, 0)
			table.insert(self.heroes, hero)
		end
	end
	
	self.allyMinions = minionManager(MINION_ALLY, 2000, myHero, MINION_SORT_HEALTH_ASC)
	self.enemyMinions = minionManager(MINION_ENEMY, 2000, myHero, MINION_SORT_HEALTH_ASC)
	self.neutralMinions = minionManager(MINION_JUNGLE, 2000, myHero, MINION_SORT_HEALTH_ASC)
	
	self.activeSpells = {}
	
	AddAnimationCallback(function(unit, animation) self:OnAnimation(unit, animation) end)
	AddDrawCallback(function() DrawText("activeSpells: " .. #self.activeSpells, 16, 10, 10, ARGB(255,255, 255, 255)) end)
	AddProcessSpellCallback(function(unit, spell) self:OnProcessSpell(unit, spell) end)
	AddRecvPacketCallback(function(p) self:OnRecvPacket(p) end)
	AddTickCallback(function() self:OnTick() end)
end

function SimplePredict:OnAnimation(unit, animation)
	if unit.type == "AIHeroClient" and (animation == "Attack1" or animation == "Attack2" or animation == "Crit" or animation == "Channel" or animation == "Run") then
		for _, hero in pairs(self.heroes) do
			if hero.networkID == unit.networkID then
				hero.isAttacking = animation ~= "Run"
				return
			end
		end
	end
end

function SimplePredict:OnProcessSpell(unit, spell)
	if spell.name:lower():find("attack") or spell.name == "frostarrow" then
		table.insert(self.activeSpells, SpellProc(unit.networkID, spell.projectileID, unit, spell.endPos, spell.windUpTime, spell.animationTime, nil, spell.target.networkID))
	end
end

function SimplePredict:OnRecvPacket(p)
	if p.header == 0xB5 then
		p.pos = 1
		local casterNetworkId = p:DecodeF()
		
		p.pos = 37
		local projectileId = p:DecodeF()
		
		p.pos = 21
		local animationTime = p:DecodeF()
		
		p.pos = 41
		local endPos = Vector(p:DecodeF(), p:DecodeF(), p:DecodeF())
		
		p.pos = 66
		local targetNetworkId = p:DecodeF()
		
		p.pos = p.size - 46
		local windUpTime = p:DecodeF()
		
		p.pos = p.size - 25
		local spellId = p:Decode1()
		
		p.pos = p.size - 20
		local startPos = Vector(p:DecodeF(), p:DecodeF(), p:DecodeF())
		
		table.insert(self.activeSpells, 
			SpellProc(casterNetworkId, projectileId, startPos, endPos, windUpTime, animationTime, spellId, targetNetworkId))
	end
end

function SimplePredict:OnTick()
	for i, spellProc in pairs(self.activeSpells) do
		if GetInGameTimer() > spellProc.startT + spellProc.animationTime then
			table.remove(self.activeSpells, i)
		end
	end
end

function SimplePredict:IsAttacking(unit)
	if unit.isAttacking then
		return true
	else
		for _, hero in pairs(self.heroes) do
			if hero.networkID == unit.networkID then
				return hero.isAttacking
			end
		end
	end
end

function SimplePredict:IsTooSlow(unit, time, radius)
	return unit.ms * (time - (self.Config.reactTime / 1000)) < radius
end

function SimplePredict:GetHitChance(unit, radius, time)
	local hitChance = 1
	if not unit.hasMovePath then
		hitChance = unit.canMove and 0 or 4
	elseif self:IsAttacking(unit) then
		hitChance = 2
	elseif self:IsTooSlow(unit, time, radius) then
		hitChance = 3
	end
	
	return hitChance
end

function SimplePredict:CheckCollision(startPos, endPos, speed, delay, radius, colTable)
	local distance = GetDistance(startPos, endPos)
	
	for _, unit in pairs(colTable) do
		local unit_distance = GetDistance(unit)
		if unit_distance < distance then
			local predictPos = self.Config.collision.predictPos and self:GetPredictedPosition(unit, delay + (unit_distance / speed), radius) or unit.visionPos
			local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(startPos, endPos, predictPos)
			if isOnSegment and GetDistance(pointSegment, predictPos) <= unit.boundingRadius + radius + self.Config.collision.extraBuffer then
				DrawLine3D(startPos.x, startPos.y, startPos.z, pointLine.x, unit.y, pointLine.y, radius + self.Config.collision.extraBuffer, ARGB(128, 255, 0, 0))
				return true
			end
		end
	end
	
	return false
end

function SimplePredict:GetCollision(startPos, endPos, speed, delay, radius, colTable)
	local obstacles = {}
	local distance = GetDistance(startPos, endPos)
	
	for _, unit in pairs(colTable) do
		local unit_distance = GetDistance(unit)
		if unit_distance < distance then
			local predictPos = self.Config.collision.predictPos and self:GetPredictedPosition(unit, delay + (unit_distance / speed), radius) or unit.visionPos
			local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(startPos, endPos, predictPos)
			if isOnSegment and GetDistance(pointSegment, predictPos) <= unit.boundingRadius + radius + self.Config.collision.extraBuffer then
				table.insert(obstacles, unit)
			end
		end
	end
	
	return obstacles
end

function SimplePredict:LogIdlePrediction(unit, delay)
	DelayAction(function()
		for _, hero in pairs(self.heroes) do
			if unit.networkID == hero.networkID then
				hero.idlePredict = (hero.idlePredict  + ((Vector(unit) - unit.visionPos):normalized())) / 2
			end
		end
	end, delay)
end

function SimplePredict:GetIdlePrediction(unit, radius)
	for _, hero in pairs(self.heroes) do
		if hero.networkID == unit.networkID then
			local prefDir = (Vector(hero) - hero.idlePredict):normalized()
			return (prefDir * radius) + unit.visionPos
		end
	end
end

function SimplePredict:GetPredictedPosition(unit, delay, radius)
	if not unit.hasMovePath then
		return unit.type == "AIHeroClient" and self:GetIdlePrediction(unit, radius) or unit.visionPos
	end
	
	local direction = (Vector(unit) - unit.visionPos):normalized()
	local predictPos =  unit + direction * ((unit.ms * delay) - radius)
	
	if unit.type == "AIHeroClient" and self.Config.predictIdle then
		self:LogIdlePrediction(unit, delay)
	end
	
	return predictPos
end

function SimplePredict:GetAOEPredictedPosition(unit, delay, radius) -- Most of this was taken out of VPrediction
	local mainPos = self:GetPredictedPosition(unit, delay, radius)
	local positions = {}
	table.insert(positions, mainPos)
	
	for _, hero in pairs(self.heroes) do
		if hero.networkID ~= unit.networkID and unit.valid and not unit.dead and unit.visible then
			local predictPos = self:GetPredictedPosition(hero, delay, radius)
			if GetDistance(mainPos, predictPos) <= radius * 2 then
				table.insert(positions, predictPos)
			end
		end
	end
	
	while #positions > 1 do
		local mec = MEC(positions)
		local circle = mec:Compute()
		
		if circle.radius <= radius then
			return circle.center, #positions
		end
		
		local index = nil
		local result = 0
		for i = 2, #positions do
			local distance = GetDistance(mainPos, positions[i])
			if distance > result then
				index = i
				result = distance
			end
		end
		
		table.remove(positions, index)
	end
	
	return mainPos, #positions
end

function SimplePredict:GetPredictedHealth(unit, delay)
	local totalDamage = 0
	
	for _, spellProc in pairs(self.activeSpells) do
		local midpoint = Vector(spellProc.startPos.x + spellProc.endPos.x, spellProc.startPos.y + spellProc.endPos.y, spellProc.startPos.z + spellProc.endPos.z) / 2
		if spellProc.caster.team ~= unit.team and GetDistance(midpoint, unit) < spellProc.lineWidth then
			if (spellProc.target and spellProc.target.networkID == unit.networkID) or checkhitlinepass(spellProc.startPos, spellProc.endPos, spellProc.lineWidth, 3000, unit, unit.boundingRadius) then
				local distance = GetDistance(spellProc.caster, unit)
				local timeToHit = GetInGameTimer()  + (spellProc.windUpTime + (spellProc.missileSpeed == math.huge and 0 or (distance / spellProc.missileSpeed))) -  spellProc.startT
				if delay > timeToHit then
					totalDamage = totalDamage + math.floor(spellProc.caster.type == "AIHeroClient" and getDmg("AA", spellProc.caster, unit) or spellProc.caster:CalcDamage(unit))
				end
			end
		end
	end
	return unit.health - totalDamage
end

class "SpellProc"

function SpellProc:__init(casterNetworkId, projectileId, startPos, endPos, windUpTime, animationTime, spellId, targetNetworkId)
	self.caster = objManager:GetObjectByNetworkId(casterNetworkId)
	self.projectileId = projectileId
	self.startPos = startPos
	self.endPos = endPos
	self.target = objManager:GetObjectByNetworkId(targetNetworkId)
	self.windUpTime = windUpTime
	self.animationTime = animationTime
	self.spellId = spellId
	self.startT = GetInGameTimer()
	
	local spellData = spellId and self.caster:GetSpellData(spellId)
	if spellData then
		self.missileSpeed = spellData.missileSpeed
		self.lineWidth = spellData.lineWidth
	else
		self.missileSpeed = projectilespeeds[self.caster.charName]
		self.lineWidth = 30
	end
end
