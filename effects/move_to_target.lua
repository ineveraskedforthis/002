local duration = 0.4
local manager = require "effects._manager"
local id, def = manager.new_effect(duration)

def.description = "Move to target"

function def.scene_update(state, battle, time_passed, dt, origin, target, scene_data)
	if (time_passed > duration) then
		return true
	end

	local progress = SMOOTHERSTEP(time_passed / duration)

	local shift_y = ACTOR_HEIGHT * 1.5
	if target.team == 0 then
		shift_y = - ACTOR_HEIGHT * 1.5
	end
	origin.x = scene_data.start_x * (1 - progress) + target.x * progress
	origin.y = scene_data.start_y * (1 - progress) + (target.y + shift_y) * progress

	return false
end

function def.scene_on_start(state, battle, origin, target, scene_data)
	scene_data.start_x = origin.x
	scene_data.start_y = origin.y
end

return id