if myHero.charName ~= "Twitch" then return end

local tDeadlyVenom = { }
local enemyHeroes = GetEnemyHeroes()
local sqr_range = 1200 ^ 2

function OnUpdateBuff(unit, buff, stacks)
	if buff.name == "twitchdeadlyvenom" and unit.team == TEAM_ENEMY then
		tDeadlyVenom[unit.index] = stacks
	end
end

function OnRemoveBuff(unit, buff)
	if buff.name == "twitchdeadlyvenom" and unit.team == TEAM_ENEMY then
		tDeadlyVenom[unit.index] = nil
	end
end

function OnDraw()
	local level = myHero:GetSpellData(_E).level
	local damage, trueHealth

	for _, enemy in pairs(enemyHeroes) do
		if tDeadlyVenom[enemy.index] and enemy.visible and not enemy.dead then
			do
				local baseDamage = 5 + 15 * level
				local stackDamage = ((10 + 5 * level) + (myHero.ap / 5) + (myHero.addDamage / 4)) * tDeadlyVenom[enemy.index]

				damage = myHero:CalcDamage(enemy, baseDamage + stackDamage)
			end

			trueHealth = enemy.health + enemy.shield

			if GetDistanceSqr(enemy) < sqr_range and damage > trueHealth then
				return CastSpell(_E)
			end

			local screenPos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
			local percentage = math.floor(damage / trueHealth * 100) .. "%"
			local midOffset = GetTextArea(percentage, 20).x / 2

			DrawText(percentage, 20, screenPos.x - midOffset, screenPos.y, ARGB(255, 255, 255, 255))
		end
	end
end
