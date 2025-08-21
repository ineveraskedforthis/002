local manager = require "effects._manager"
local duration = 0.5
local actual_dot = require "effects.basic_dot"
local id, def = manager.new_effect(duration)
def.description = "Activate old dots and apply new dot"

function def.target_effect(origin, target, scene_data)
	for _, value in ipairs(target.status_effects) do
		local dot_definition = manager.get(value.def)
		if value.def == actual_dot then
			dot_definition.target_effect(value.origin, target, scene_data)
		end
	end
	APPLY_EFFECT(origin, target, actual_dot)
end

function def.scene_render(time_passed, origin, target, scene_data)
	local progress = time_passed / duration
	local x = progress * target.x + (1 - progress) * origin.x
	local y = progress * target.y + (1 - progress) * origin.y
	love.graphics.setColor(0, 0.5, 0, 1)
	love.graphics.circle("fill", x, y, 10)
end

return id