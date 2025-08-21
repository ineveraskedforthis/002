local manager = require "effects._manager"
local duration = 0.01
local id, def = manager.new_effect(duration)
def.description = "Deal [100% of MAG] damage. Ignore defense."

function def.target_effect(origin, target, scene_data)
	local damage = TOTAL_MAG_ACTOR(origin)
	DEAL_DAMAGE(origin, target, damage)
end

return id