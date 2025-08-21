local manager = require "effects._manager"
local duration = 0.5
local id, def = manager.new_effect(duration)

def.description = "Deal [100% of STR + 100% of MAG] AOE damage"

function def.target_effect(origin, target)
	for index, value in ipairs(BATTLE) do
		if target.team == value.team then
			DEAL_DAMAGE(origin, value, 1, 1, 0)
		end
	end
end

function def.scene_render(time_passed, origin, target, scene_data)
	local progress = SMOOTHERSTEP(time_passed / duration)

	love.graphics.setColor(1, 0.0, 0.0, 1)

	local x_left = 9999
	local x_right = 0

	local y = 0
	local count = 0

	for index, value in ipairs(BATTLE) do
		if target.team == value.team and target.visible then
			x_right = math.max(value.x + 100, x_right)
			if x_left > value.x then
				x_left = value.x
			end
			y = y + value.y
			count = count + 1
		end
	end

	y = y / count

	love.graphics.rectangle("fill", x_left - 10, y + 10, (x_right - x_left) * progress, 10)
end
function def.scene_on_start(origin, target)
	if origin.definition.attack_sound then
		origin.definition.attack_sound:stop()
		origin.definition.attack_sound:play()
	end
end

return id