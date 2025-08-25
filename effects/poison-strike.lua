local manager = require "effects._manager"
local duration = 1
local id, def = manager.new_effect(duration)
def.description = "Deal [100% of STR] damage to target for every active dot."
local actual_dot = require "effects.basic_dot"

function def.target_effect(state, battle, origin, target)
	local count_dots = 0
	for _, value in ipairs(target.status_effects) do
		local dot_definition = manager.get(value.def)
		if value.def == actual_dot then
			count_dots = count_dots + 1
		end
	end
	local damage = TOTAL_STR_ACTOR(origin) * count_dots
	DEAL_DAMAGE(state, battle, origin, target, damage)
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