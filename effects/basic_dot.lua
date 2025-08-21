local manager = require "effects._manager"
local duration = 0.01
local id, def = manager.new_effect(duration)
def.description = "Deal [100% of MAG] damage. Ignore defense."

function def.target_effect(origin, target, scene_data)
	DEAL_DAMAGE(origin, target, 0, 1, 0)
end

return id