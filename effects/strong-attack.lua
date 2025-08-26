local manager = require "effects._manager"
local duration = 0.6
local id, def = manager.new_effect(duration)
def.description = "Deal [1000% of STR] x [weapon damage] x [1 + weapon mastery] damage."

function def.target_effect(state, battle, origin, target, scene_data)
	local mastery = WEAPON_MASTERY_ACTOR(origin)
	local from_weapon = WEAPON_ADD_DAMAGE(origin.definition.weapon)
	local damage = 10 * TOTAL_STR_ACTOR(origin) * from_weapon * (1 + mastery)
	local negated_damage = target.definition.DEF
	local final_damage = math.max(0, damage - negated_damage)

	DEAL_DAMAGE(state, battle, origin, target, final_damage)
end

function def.scene_render(state, battle, time_passed, origin, target, scene_data)
	local progress = SMOOTHERSTEP(time_passed / duration)
	love.graphics.line(
		target.x - 10,
		target.y - 10,
		target.x - 10 + (ACTOR_WIDTH + 20) * progress,
		target.y - 10 + (ACTOR_HEIGHT + 20) * progress
	)
end

function def.scene_on_start(state, battle, origin, target, scene_data)
	if origin.definition.attack_sound then
		origin.definition.attack_sound:stop()
		origin.definition.attack_sound:play()
	end
end

return id