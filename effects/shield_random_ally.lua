local duration = 0.01

local manager = require "effects._manager"
local id, def = manager.new_effect(duration)
def.description = "Add [5% of Max HP] shield to a random ally."

function def.target_selection(state, battle, origin)
	local potential_targets = {}
	local count = 0
	for index, value in ipairs(battle.actors) do
		if value ~= origin and value.team == origin.team and value.HP > 0 then
			table.insert(potential_targets, value)
			count = count + 1
		end
	end
	local dice_roll = love.math.random(count)
	return potential_targets[dice_roll]
end

function def.target_effect (state, battle, origin, target)
	if target then
		ADD_SHIELD(origin, target, 0.05, 0, 2)
	end
end

return id