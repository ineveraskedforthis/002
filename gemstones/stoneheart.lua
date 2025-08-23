local manager = require "gemstones._manager"

local id, def = manager.new_gemstone("Stoneheart")

def.description = "Provides base shield. Provides shield every turn. Provides shield after taking damage from others."
def.base_shield = 50

function def.on_turn_start(state, battle, origin)
	ADD_SHIELD(origin, origin, 10)
end

function def.on_damage_received_effect(state, battle, origin, target, amount)
	if origin ~= target then
		ADD_SHIELD(target, target, amount * 0.2 + 5)
	end
end

return id