--[[
	  ____                ___             ___     __
	 / __ \___  ___ ___  / _ \_______ ___/ (_)___/ /_
	/ /_/ / _ \/ -_) _ \/ ___/ __/ -_) _  / / __/ __/
	\____/ .__/\__/_//_/_/  /_/  \__/\_,_/_/\__/\__/
	    /_/		Open-source Prediction Library.
]]

-- PREREQUISITE
if _G.OpenPredict then return end

function D3DXVECTOR3:__mul(FLOAT) self.x = self.x * FLOAT; self.y = self.y * FLOAT; self.z = self.z * FLOAT; return self end
function D3DXVECTOR3:__div(FLOAT) self.x = self.x / FLOAT; self.y = self.y / FLOAT; self.z = self.z / FLOAT; return self end

class("predictInfo")

-- CONSTANTS
local TYPE_HERO = "AIHeroClient"

local GAIN_VISION = 0x2E
local LOSE_VISION = 0x5B

-- GLOBALS
local polarCoords = { }
local hiddenUnits = { }

-- CALLBACKS
function OnNewPath(unit, startPos, endPos, isDash, dashSpeed--[[, dashGravity, dashDistance]])
	if unit.type == TYPE_HERO then -- Only track hero paths
		if unit.controlled then -- Path analysis will not work for AI
			local dx, dy = (endPos.x - unit.x), (endPos.z - unit.z)
			local r = math.sqrt(dx ^ 2 + dy ^ 2)
			local theta = math.atan2(dx, dy) * 57.2957795

			-- Add new coords to table
			if polarCoords[unit.networkID] then
				local theta2 = polarCoords[unit.networkID].theta
				polarCoords[unit.networkID] = { r = r, theta = theta, delta = theta > theta2 and theta - theta2 or theta2 - theta  }
			else
				polarCoords[unit.networkID] = { r = r, theta = theta, delta = 0 }
			end
		end
	end
end

function OnRecvPacket(p)
	if p.header == GAIN_VISION then
		local networkID = p:DecodeF() -- p:Decode4()
		local unit = objManager:GetObjectByNetworkId(networkID)

		if unit and unit.valid and unit.type == TYPE_HERO then
			hiddenUnits[networkID] = nil
		end
	elseif p.header == LOSE_VISION then
		local networkID = p:DecodeF() -- p:Decode4()
		local unit = objManager:GetObjectByNetworkId(networkID)

		if unit and unit.valid and unit.type == TYPE_HERO then
			hiddenUnits[networkID] = { startT = os.clock(), path = CopyNavigationPath(unit.path) }
		end
	end
end

function GetPrediction(unit, spellData)
  assert(unit and type(spellData) == "table", "GetPrediction(CUnit, table)")

  local delay, speed, width, range, source = spellData["delay"] or 0, spellData["speed"] or math.huge, spellData["width"] or 0, spellData["range"] or 0, spellData["source"] or myHero
  local pI = predictInfo()

  if (unit.isMoving and unit.hasMovePath) or not unit.visible then
		local navPath, prevPath = unit.path, unit.pos
		local tA, miaTime = 0, 0

		-- Overwrite the navPath if unit is invisible
		if hiddenUnits[unit.networkID] then
			local data = hiddenUnits[unit.networkID]

			if os.clock() - data.startT < delay + range / speed then
				navPath = data.path
				miaTime = os.clock() - data.startT
			else
				return
			end
		end

		for i = navPath.curPath, navPath.count do
			local path, tB = navPath:Path(i)

			if path then
				-- Calculate the distance across current path
				local d = math.sqrt((prevPath.x - path.x) ^ 2 + (prevPath.z - path.z) ^ 2)

				if miaTime < delay + miaTime + d / unit.ms then
					-- Check how much of the navigation path delay will cover
					if i == navPath.curPath and d / unit.ms > delay then
						-- Extend prevPath to vector after delay
						prevPath = prevPath + ((path - prevPath) / d) * (unit.ms * (miaTime + delay))

						-- Recalculate the distance
						d = math.sqrt((prevPath.x - path.x) ^ 2 + (prevPath.z - path.z) ^ 2)
					end

					do -- Calculate the interception point
						local p1, v1, s1, p2, s2 = prevPath, (path - prevPath) / d, unit.ms, source, speed
						local a = (v1.x * v1.x) + (v1.z * v1.z) - (s2 * s2)
						local b = 2 * (v1.x * (p1.x - p2.x) + v1.z * (p1.z - p2.z))
						local c = (p1.x * p1.x) + (p1.z * p1.z) + (p2.x * p2.x) + (p2.z * p2.z) - (2 * p2.x * p1.x) - (2 * p2.z * p1.z)

						local disc = b * b - 4 * a * c
						local t1 = (-b + math.sqrt(disc)) / (2 * a)
						local t2 = (-b - math.sqrt(disc)) / (2 * a)

						tB = tA + d / unit.ms
						t1, t2 = (t1 and t1 > tA and t1 < tB - tA) and t1 or nil, (t2 and t2 > tA and t2 < tB - tA) and t2 or nil
						local t = (t1 and t2 and math.min(t1, t2) or t1 or t2)

						if t then
							pI:setPredictPos(p1 + (v1 * s1 * t))

							-- Credits to gReY for the following:
							local alpha = (math.atan2(path.z - prevPath.z, path.x - prevPath.x) - math.atan2(source.z - pI.mPredictPos.z, source.x - pI.mPredictPos.x)) % (2 * math.pi) -- Angle between movement and spell
							local total = 1 - (math.abs((alpha % math.pi) - math.pi / 2) / (math.pi / 2)) -- 0: Walking in parallel direction 1: Walking orthagonal direction
							local phi = alpha < math.pi and math.atan((width / 2) / (delay + speed * t)) or -math.atan((width / 2) / (delay + speed * t))
							-- Rotate the vector
							local dx, dy = pI.mPredictPos.x - source.x, pI.mPredictPos.z - source.z
							pI:setCastPos(D3DXVECTOR3(math.cos(phi) * dx - math.sin(phi) * dy + source.x, pI.mPredictPos.y, math.sin(phi) * dx + math.cos(phi) * dy + source.z))

							return pI
						end
					end

					miaTime = math.max(0, miaTime - d / unit.ms)
				end
			end

			-- Path isn't our "golden" path, save current cumulated data and continue
			prevPath = path; tA = tB
		end

		pI:setPredictPos(navPath.endPath)

		-- Credits to gReY for the following:
		local alpha = (math.atan2(navPath.endPath.z - navPath.startPath.z, navPath.endPath.x - navPath.startPath.x) - math.atan2(source.z - navPath.endPath.z, source.x - navPath.endPath.x)) % (2 * math.pi) -- Angle between movement and spell
		local total = 1 - (math.abs((alpha % math.pi) - math.pi / 2) / (math.pi / 2)) -- 0: Walking in parallel direction 1: Walking orthagonal direction
		local timeToHit = delay + GetDistance(source, navPath.endPath) / speed
		local phi = alpha < math.pi and math.atan((width / 2) / (speed * timeToHit)) or -math.atan((width / 2) / (speed * timeToHit))
		-- Rotate the vector
		local dx, dy = navPath.endPath.x - source.x, navPath.endPath.z - source.z
		pI:setCastPos(D3DXVECTOR3(math.cos(phi) * dx - math.sin(phi) * dy + source.x, navPath.endPath.y, math.sin(phi) * dx + math.cos(phi) * dy + source.z))
	else
		pI:setPredictPos(unit)
    pI:setCastPos(unit)
	end

	return pI
end

-- UTILITY FUNCTIONS
function CopyNavigationPath(path) -- Spudgy fix CalculatePath/NavigationPath pls ty.
	local navPath = {
		valid = path.valid,
		count = path.count,
		curPath = path.curPath,
		startPath = path.startPath,
		endPath = path.endPath,
		path = {}
	}

	for i = 1, path.count do
		table.insert(navPath.path, path:Path(i))
	end

	navPath.Path = function(index)
		return navPath[index]
	end

	return navPath
end

-- PREDICT INFO CLASS
function predictInfo:__init()
  self.x = 0; self.y = 0; self.z = 0
  self.mCastPos = D3DXVECTOR3(0, 0, 0)
  self.mPredictPos = D3DXVECTOR3(0, 0, 0)
end

function predictInfo:setPredictPos(p)
  self.mPredictPos = D3DXVECTOR3(p.x, p.y, p.z)
end

function predictInfo:setCastPos(p)
  self.x = p.x; self.y = p.y; self.z = p.z
  self.mCastPos = D3DXVECTOR3(p.x, p.y, p.z)
end

PrintChat("<font color=\"#1E90FF\"><b>[OpenPredict]</b> </font><font color=\"#FFFFFF\">Loaded</font>")
