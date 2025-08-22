local manager = require "effects._manager"
local duration = 1
local id, def = manager.new_effect(duration)
def.description = "Deal [150% of STR] damage. Delay target's action"

function def.target_effect(state, battle, origin, target)
	local damage = TOTAL_STR_ACTOR(origin) * 1.5
	local negated_damage = target.definition.DEF
	local final_damage = math.max(0, damage - negated_damage)

	DEAL_DAMAGE(state, battle, origin, target, final_damage)
	target.action_number = target.action_number + SPEED_TO_ACTION_OFFSET(target.definition.SPD)
end

function def.scene_render(state, battle, time_passed, origin, target, scene_data)
	local progress = SMOOTHERSTEP(time_passed / duration * time_passed / duration)

	love.graphics.line(
		target.x - 10,
		target.y - 10,
		target.x - 10 + (ACTOR_WIDTH + 20) * progress,
		target.y - 10 + (ACTOR_HEIGHT + 20) * progress
	)

	love.graphics.line(
		target.x - 10 - 3,
		target.y - 10 + 3,
		target.x - 10 - 3 + (ACTOR_WIDTH + 20) * progress,
		target.y - 10 + 3 + (ACTOR_HEIGHT + 20) * progress
	)

	love.graphics.line(
		target.x - 10 + 3,
		target.y - 10 - 3,
		target.x - 10 + 3 + (ACTOR_WIDTH + 20) * progress,
		target.y - 10 - 3 + (ACTOR_HEIGHT + 20) * progress
	)
end

function def.scene_on_start(state, battle, origin, target)
	if origin.definition.attack_sound then
		origin.definition.attack_sound:stop()
		origin.definition.attack_sound:play()
	end
end

return id