local manager = require "effects._manager"
local duration = 0.6
local id, def = manager.new_effect(duration)
def.description = "Deal [100% of STR] damage."

function def.target_effect(origin, target, scene_data)
	DEAL_DAMAGE(origin, target, 1, 0, 1)
end

function def.scene_render(time_passed, origin, target, scene_data)
	local progress = SMOOTHERSTEP(time_passed / duration)
	love.graphics.line(
		target.x - 10,
		target.y - 10,
		target.x - 10 + (ACTOR_WIDTH + 20) * progress,
		target.y - 10 + (ACTOR_HEIGHT + 20) * progress
	)
end

function def.scene_on_start(origin, target, scene_data)
	if origin.definition.attack_sound then
		origin.definition.attack_sound:stop()
		origin.definition.attack_sound:play()
	end
end

return id