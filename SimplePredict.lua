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
		local predictPos = SimplePredict:GetAOEPredictedPosition(unit, delay, radius)
	
	Hit Chance:
		0 - Unit is not moving
		1 - Unit is moving
		2 - Unit is attacking
		3 - Unit is too slow (~100%)
		4 - Unit is immobile (~100%)
		5 - Unit is dashing/blinking (~100%)
	
	Thanks to Honda7 for his VPrediction library
]]

class "SimplePredict"

function SimplePredict:__init()
	self.Config = scriptConfig("SimplePredict", "SimplePredict")
		self.Config:addSubMenu("Collision", "collision")
			self.Config.collision:addParam("predictPos", "Predict Obstacle Positions", SCRIPT_PARAM_ONOFF, true)
			--self.Config.collision:addParam("predictHp", "Predict Obstacle Health", SCRIPT_PARAM_ONOFF, false)
			self.Config.collision:addParam("extraBuffer", "Extra Collision Buffer", SCRIPT_PARAM_SLICE, 20, 0, 50, 0)
			
		self.Config:addParam("predictIdle", "Use Idle Prediction", SCRIPT_PARAM_ONOFF, true)
		self.Config:addParam("reactTime", "Player Reaction Time (ms)", SCRIPT_PARAM_SLICE, 215, 0, 500, 0)
		self.Config:addParam("debug", "Debug Mode (Drawing)", SCRIPT_PARAM_ONOFF, false)
	
	self.heroes = {}
	for i = 1, heroManager.iCount do
		local hero = heroManager:GetHero(i)
		if hero.team == TEAM_ENEMY then -- Only insert enemies
			hero.idlePredict = Vector(0, 0, 0)
			table.insert(self.heroes, hero)
		end
	end
	
	AddAnimationCallback(function(unit, animation) self:OnAnimation(unit, animation) end)
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
	return unit.ms * (time - self.Config.reactTime) < radius * 2
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

function SimplePredict:GetAOEPredictedPosition(unit, delay, radius)
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
