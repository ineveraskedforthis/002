local manager = require "effects._manager"
local duration = 0.8
local id, def = manager.new_effect(duration)
def.description = "Deal [50% of MAG] damage."

function def.target_effect(state, battle, origin, target)
	DEAL_DAMAGE(state, battle, origin, target, TOTAL_MAG_ACTOR(origin) * 0.5)
end

function def.scene_render(state, battle, time_passed, origin, target, scene_data)
	local progress = time_passed / duration

	local x = progress * target.x + (1 - progress) * origin.x
	local y = progress * target.y + (1 - progress) * origin.y

	love.graphics.setColor(1, 0.5, 1, 1)
	love.graphics.circle("fill", x, y, 10)
end

return id