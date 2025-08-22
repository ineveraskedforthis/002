local manager = require "effects._manager"
local duration = 0.8
local id, def = manager.new_effect(duration)
def.description = "Deal [100% of MAG + 500% of current HP] damage. Consume 50% of HP."

function def.target_effect(state, battle, origin, target)
	local mag = TOTAL_MAG(origin.definition, origin.wrapper)
	local hp = origin.HP

	local damage_target = mag + 5 * hp
	local damage_origin = 0.5 * hp

	DEAL_DAMAGE(state, battle, origin, origin, damage_origin)
	DEAL_DAMAGE(state, battle, origin, target, damage_target)
end

function def.scene_render(state, battle, time_passed, origin, target, scene_data)
	local progress = time_passed / duration

	local x = progress * target.x + (1 - progress) * origin.x
	local y = progress * target.y + (1 - progress) * origin.y

	love.graphics.setColor(1, 0, 0, 1)
	love.graphics.line(x, y, origin.x, origin.y, origin.x + ACTOR_WIDTH, origin.y, x, y)
end

return id