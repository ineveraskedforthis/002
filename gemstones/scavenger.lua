local manager = require "gemstones._manager"

local id, def = manager.new_gemstone("Scavenger")

def.additional_hp = 100
def.additional_mag = 10
def.description = "Increase your magic ability and hitpoints. Deal damage to yourself every turn and restore HP on kill and damage dealt."

function def.on_turn_start(origin)
	DEAL_DAMAGE(origin, origin, 30)
end

function def.on_kill_effect(origin, target)
	RESTORE_HP(origin, origin, TOTAL_MAX_HP_ACTOR(target))
end

function def.on_damage_dealt_effect(origin, target, amount)
	if origin ~= target then
		RESTORE_HP(origin, origin, amount * 0.5)
	end
end

return id