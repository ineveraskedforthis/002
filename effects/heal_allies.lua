local manager = require "effects._manager"
local duration = 0.01
local id, def = manager.new_effect(duration)

def.description = "Restore [150% of MAG] HP to all allies"

function def.multi_target_selection(origin)
	local targets = {}
	for index, value in ipairs(BATTLE) do
		if value.team == origin.team then
			table.insert(targets, value)
		end
	end
	return targets
end

function def.target_effect(origin, target)
	RESTORE_HP(origin, target, 1.5)
end

return id