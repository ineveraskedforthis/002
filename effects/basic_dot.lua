local manager = require "effects._manager"
local duration = 0.01
local id, def = manager.new_effect(duration)
def.description = "Deal [100% of MAG] damage. Ignore defense."

function def.target_effect(state, battle, origin, target, scene_data)
	local damage = TOTAL_MAG_ACTOR(origin)
	DEAL_DAMAGE(state, battle, origin, target, damage)
end

function def.utility(state, battle, origin, target, scene_data)
	local mult = 1
	if target.team == origin.team then
		mult = -1
	end
	local damage = TOTAL_MAG_ACTOR(origin)
	return damage * mult * 5
end

return id