local manager = require "effects._manager"
local duration = 0.01
local id, def = manager.new_effect(duration)

def.description = "Restore [150% of MAG] HP to all allies"

function def.multi_target_selection(state, battle, origin)
	local targets = {}
	for index, value in ipairs(battle.actors) do
		if value.team == origin.team then
			table.insert(targets, value)
		end
	end
	return targets
end

function def.target_effect(state, battle, origin, target)
	RESTORE_HP(state, battle, origin, target, 1.5 * TOTAL_MAG_ACTOR(origin))
end

function def.utility(state, battle, origin, target, scene_data)
	local mult = 1
	if target.team ~= origin.team then
		mult = -1
	end

	local total = 0

	local damage = 1.5 * TOTAL_MAG_ACTOR(origin)

	for index, value in ipairs(battle.actors) do
		if value.team == origin.team then
			total = total + damage
		end
	end

	return mult * damage
end

return id