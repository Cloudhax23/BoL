--[[
	SimplePredict alpha
		a lightweight prediction library
	
	SP = SimplePredict()
	
	Methods:
		local distance = SimplePredict:GetDistance2D(a, b)
		local isAttacking = SimplePredict:IsAttacking(unit)
		local isTooSlow = SimplePredict:IsTooSlow(unit, time, radius)
		local hitChance = SimplePredict:GetHitChance(unit, radius, delay)
		local collision = SimplePredict:CheckCollision(startPos, endPos, speed, delay, radius, colTable)
		local obstacles = SimplePredict:GetCollision(startPos, endPos, speed, delay, radius, colTable)
		local predictPos = SimplePredict:GetIdlePrediction(unit, radius)
		local predictPos = SimplePredict:GetPredictedPosition(unit, delay, radius)
	
	Hit Chance:
		0 - Unit is not moving
		1 - Unit is moving
		2 - Unit is attacking
		3 - Unit is too slow (~100%)
		4 - Unit is immobile (~100%)
		5 - Unit is dashing/blinking (~100%)
]]

class "SimplePredict"

function SimplePredict:__init()
	self.Config = scriptConfig("SimplePredict", "SimplePredict")
		self.Config:addSubMenu("Collision", "collision")
			self.Config.collision:addParam("predictPos", "Predict Obstacle Positions", SCRIPT_PARAM_ONOFF, false)
			self.Config.collision:addParam("predictHp", "Predict Obstacle Health", SCRIPT_PARAM_ONOFF, false)
			self.Config.collision:addParam("extraBuffer", "Extra Collision Buffer", SCRIPT_PARAM_SLICE, 20, 0, 50, 0)
			
		self.Config:addParam("predictIdle", "Use Idle Prediction", SCRIPT_PARAM_ONOFF, true)
	
	self.heroes = {}
	for i = 1, heroManager.iCount do
		local hero = heroManager:GetHero(i)
		hero.idlePredict = Vector(0, 0, 0)
		table.insert(self.heroes, hero)
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

function SimplePredict:GetDistance2D(a, b)
	local b = b or myHero
	return math.sqrt((b.x - a.x) ^ 2 + (b.y - a.y) ^ 2)
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
	return unit.ms * time < radius * 2
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
	local distance = self:GetDistance2D(startPos, endPos)
	
	for _, unit in pairs(colTable) do
		local unit_distance = self:GetDistance2D(unit)
		if unit_distance < distance then
			local predictPos = self:GetPredictedPosition(unit, delay + (unit_distance / speed), radius)
			local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(startPos, endPos, predictPos)
			if isOnSegment and self:GetDistance2D(pointSegment, endPos) <= unit.boundingRadius + radius + self.Config.collision.extraBuffer then
				return true
			end
		end
	end
	return false
end

function SimplePredict:GetCollision(startPos, endPos, speed, delay, radius, colTable)
	local obstacles = {}
	local distance = self:GetDistance2D(startPos, endPos)
	
	for _, unit in pairs(colTable) do
		local unit_distance = self:GetDistance2D(unit)
		if unit_distance < distance then
			local predictPos = self:GetPredictedPosition(unit, delay + (unit_distance / speed), radius)
			local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(startPos, endPos, predictPos)
			if isOnSegment and self:GetDistance2D(pointSegment, endPos) <= unit.boundingRadius + radius + self.Config.collision.extraBuffer then
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
