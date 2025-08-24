local manager = require "effects._manager"
local duration = 0.1
local id, def = manager.new_effect(duration)

local move_back = require "effects.move_to_original_position"

def.description = "Launches 5 attacks against random targets. If one of them dies, add 5 more attacks"

function def.scene_render(state, battle, time_passed, origin, target, scene_data)
	local progress = SMOOTHERSTEP(time_passed / duration)

	love.graphics.line(
		target.x - 10,
		target.y - 10,
		target.x - 10 + (ACTOR_WIDTH + 20) * progress,
		target.y - 10 + (ACTOR_HEIGHT + 20) * progress
	)
end


function def.target_effect(state, battle, origin, target, data)
	if target.HP <= 0 then
		---@type Effect
		local go_back = {
			data = {
				counter = data.counter - 1,
			},
			def = move_back,
			origin = origin,
			target = origin,
			started = false,
			time_passed = 0,
			times_activated = 0
		}
		table.insert(battle.effects_queue, go_back)
		return
	end

	local damage = TOTAL_MAG_ACTOR(origin) + TOTAL_STR_ACTOR(origin) * 0.25

	DEAL_DAMAGE(state, battle, origin, target, damage)

	if target.HP <= 0 then
		---@type number
		data.counter = data.counter + 5
	end

	local go_back = false

	if (data.counter > 0) then
		-- select random target

		---@type Actor[]
		local potential_targets = {}
		local count = 0
		for index, value in ipairs(battle.actors) do
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

			table.insert(battle.effects_queue, next_attack)
		else
			go_back = true
		end
	else
		go_back = true
	end

	if go_back then
		table.insert(battle.effects_queue, {
			data = {
				counter = data.counter - 1,
			},
			def = move_back,
			origin = origin,
			target = origin,
			started = false,
			time_passed = 0,
			times_activated = 0
		})
	end
end

function def.scene_update(state, battle, time_passed, dt, origin, target, scene_data)
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

function def.scene_on_start(state, battle, origin, target, data)
	if data.counter == nil then
		data.counter = 5
	end
end

return id