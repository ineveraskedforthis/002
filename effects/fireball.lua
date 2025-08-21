local manager = require "effects._manager"
local duration = 0.8
local id, def = manager.new_effect(duration)

def.description = "Deal [200% of MAG] damage"

function def.target_effect(origin, target, data)
	local target_damage = TOTAL_MAG_ACTOR(origin) * 2
	local aoe_damage = TOTAL_MAG_ACTOR(origin) * 0.75
	DEAL_DAMAGE(origin, target, target_damage)
	for index, value in ipairs(BATTLE) do
		if target.team == value.team then
			DEAL_DAMAGE(origin, value, aoe_damage)
		end
	end
end

function def.scene_render(time_passed, origin, target, scene_data)
	local progress = time_passed / duration

	local x = progress * target.x + (1 - progress) * origin.x
	local y = progress * target.y + (1 - progress) * origin.y

	love.graphics.setColor(1, 0.4, 0.4, 1)
	love.graphics.circle("fill", x, y, 10)
end

return id