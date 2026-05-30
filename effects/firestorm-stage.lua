local manager = require "effects._manager"
local duration = 0.5
local id, def = manager.new_effect(duration)

def.description = "Deal [50% of MAG] damage to everyone"

function def.target_effect(state, battle, origin, target, data)
	for _, value in ipairs(battle.actors) do
		if target.team == value.team then
			DEAL_DAMAGE(state, battle, origin, value, TOTAL_MAG_ACTOR(origin) * 0.5)
		end
	end
end

function def.utility(state, battle, origin, target, scene_data)
	local mult = 1
	if target.team == origin.team then
		mult = -1
	end

	local damage = TOTAL_MAG_ACTOR(origin) * 0.5
	local total = 0

	for _, value in ipairs(battle.actors) do
		if target.team == value.team then
			total = total + damage
		end
	end

	return mult * total
end

function def.scene_render(state, battle, time_passed, origin, target, scene_data)
	local progress = time_passed / duration
	local fall = 300 + SMOOTHERSTEP(progress * progress) * (-300)
	love.graphics.setColor(1, 0.4, 0.4, progress + 0.1)
	for index, value in ipairs(battle.actors) do
		if target.team == value.team and target.HP > 0 then
			love.graphics.circle("fill", value.x, value.y + fall, 10)
		end
	end
end

return id