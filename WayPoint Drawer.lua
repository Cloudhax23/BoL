local wayPointManager = WayPointManager()

function OnLoad()
	Config = scriptConfig("WayPoints", "wayPoints")
	
	Config:addParam("drawMinimap", "Draw on minimap", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("drawETA", "Draw ETA", SCRIPT_PARAM_ONOFF, true)
	
	Config:addSubMenu("Allies", "allies")
	Config.allies:addParam("enabled", "Enabled", SCRIPT_PARAM_ONOFF, true)
	Config.allies:addParam("color", "Color", SCRIPT_PARAM_COLOR, {255, 0, 255, 255})
	Config:addSubMenu("Enemies", "axis")
	Config.axis:addParam("enabled", "Enabled", SCRIPT_PARAM_ONOFF, true)
	Config.axis:addParam("color", "Color", SCRIPT_PARAM_COLOR, {255, 255, 0, 0})
end

function OnDraw()
	for i=1, heroManager.iCount do
		local hero = heroManager:getHero(i)
		if (Config.allies.enabled and hero.team ~= TEAM_ENEMY) or (Config.axis.enabled and hero.team == TEAM_ENEMY) then
			local wayPoints, fTime = wayPointManager:GetSimulatedWayPoints(hero)
			local points = {}
			local color = hero.team == TEAM_ENEMY and Config.axis.color or Config.allies.color
				
			for k=2, #wayPoints do
				DrawLine3D(wayPoints[k-1].x, hero.y, wayPoints[k-1].y, wayPoints[k].x, hero.y, wayPoints[k].y, 1, ARGB(color[1], color[2], color[3], color[4]))
				
				if Config.drawMinimap and not hero.isMe then
					DrawLine(GetMinimapX(wayPoints[k-1].x-128), GetMinimapY(wayPoints[k-1].y+128), GetMinimapX(wayPoints[k].x-128), GetMinimapY(wayPoints[k].y+128), 1, ARGB(color[1], color[2], color[3], color[4]))
				end
					
				if Config.drawETA then
					local seconds = math.floor(fTime%60)
					DrawText3D(math.floor(fTime/60)..":".. (seconds > 9 and seconds or "0"..seconds), wayPoints[#wayPoints].x, hero.y, wayPoints[#wayPoints].y, 16, ARGB(color[1], color[2], color[3], color[4]))
				end
			end
		end
	end
end
