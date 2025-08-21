local manager = require "effects._manager"
local duration = 0.1
local id, def = manager.new_effect(duration)

def.description = "Launches 5 attacks against random targets. If one of them dies, add 5 more attacks"

function def.scene_render(time_passed, origin, target, scene_data)
	local progress = SMOOTHERSTEP(time_passed / duration)

	love.graphics.line(
		target.x - 10,
		target.y - 10,
		target.x - 10 + (ACTOR_WIDTH + 20) * progress,
		target.y - 10 + (ACTOR_HEIGHT + 20) * progress
	)
end


function def.target_effect(origin, target, data)
	if target.HP <= 0 then
		return
	end

	DEAL_DAMAGE(origin, target, 0.25, 1.0, 0.5)

	if target.HP <= 0 then
		---@type number
		data.counter = data.counter + 5
	end

	if (data.counter > 0) then
		-- select random target

		---@type Actor[]
		local potential_targets = {}
		local count = 0
		for index, value in ipairs(BATTLE) do
			if value.team ~= origin.team and value.HP > 0 then
				table.insert(potential_targets, value)
				count = count + 1
			end
		end
		local dice_roll = love.math.random(count)

		local random_target = potential_targets[dice_roll]

		if random_target then
			---@type Effect
			local next_attack = {
				data = {
					counter = data.counter - 1,
				},
				def = id,
				origin = origin,
				target = random_target,
				started = false,
				time_passed = 0,
				times_activated = 0
			}

			table.insert(EFFECTS_QUEUE, next_attack)
		end
	end
end

function def.scene_update(time_passed, dt, origin, target, scene_data)
	if (time_passed > duration) then
		return true
	end

	origin.x = target.x
	origin.y = target.y

	if scene_data.counter % 4 == 0 then
		origin.y = origin.y + ACTOR_HEIGHT
	elseif scene_data.counter % 4 == 1 then
		origin.y = origin.y - ACTOR_HEIGHT
	elseif scene_data.counter % 4 == 2 then
		origin.x = origin.x - ACTOR_WIDTH
	elseif scene_data.counter % 4 == 3 then
		origin.x = origin.x + ACTOR_WIDTH
	end

	return false
end

function def.scene_on_start(origin, target, data)
	if data.counter == nil then
		data.counter = 5
	end
end

return id