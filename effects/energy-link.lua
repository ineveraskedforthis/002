local manager = require "effects._manager"
local duration = 0.2
local id, def = manager.new_effect(duration)

local move_back = require "effects.move_to_original_position"
local actor_image = require "ui.actor"

def.description = "Beam of energy jumps 10 times dealing 50% more damage at every step. Starting damage is [25% of MAG]."

function def.scene_render(state, battle, time_passed, origin, target, scene_data)
	---@type EnergyLinkData
	scene_data = scene_data

	local alpha = time_passed / duration
	local progress = SMOOTHERSTEP(1 - math.abs(1 - alpha * 2))

	love.graphics.setColor(0, 0, 0, progress)
	love.graphics.setLineWidth(5)
	love.graphics.line(scene_data.path)
	love.graphics.setColor(1, 1, 1, progress)
	love.graphics.setLineWidth(3)
	love.graphics.line(scene_data.path)

	love.graphics.setLineWidth(1)
end

---@class EnergyLinkData
---@field damage number
---@field counter number
---@field path number[]
---@field x number
---@field y number

function def.target_effect(state, battle, origin, target, data)
	---@type EnergyLinkData
	data = data

	if data.counter == 0 then
		return
	end

	DEAL_DAMAGE(state, battle, origin, target, data.damage)

	if target.HP <= 0 then
		origin.energy = origin.energy + 2
	end

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
			data = data,
			def = id,
			origin = origin,
			target = random_target,
			started = false,
			time_passed = 0,
			times_activated = 0
		}

		table.insert(battle.effects_queue, next_attack)
	end
end

function def.scene_update(state, battle, time_passed, dt, origin, target, scene_data)
	if (time_passed > duration) then
		return true
	end

	return false
end

function def.scene_on_start(state, battle, origin, target, data)
	---@type EnergyLinkData
	data = data

	if data.counter == nil then
		data.counter = 10
		local sx, sy, sw, sh = actor_image.get_rect(state, battle, origin.x, origin.y, origin)
		data.x = sx + sw / 2
		data.y = sy + sh / 2
		data.damage = TOTAL_MAG_ACTOR(origin) * 0.25
	else
		data.damage = data.damage * 1.5
		data.counter = data.counter - 1
	end

	data.path = {}

	-- generate 5 segments


	local start_x = data.x
	local start_y = data.y

	local sx, sy, sw, sh = actor_image.get_rect(state, battle, target.x, target.y, target)

	local end_x = sx + sw / 2
	local end_y = sy + sh / 2

	for i = 0, 5 do
		local t = i / 5
		local cx = start_x * t + end_x * (1 - t) + love.math.randomNormal() * 4
		local cy = start_y * t + end_y * (1 - t) + love.math.randomNormal() * 4
		table.insert(data.path, cx)
		table.insert(data.path, cy)



		for i = 0, 5 do
			local angle = love.math.random() * math.pi * 2

			state.vfx.new_particle(
				cx, cy, math.cos(angle) * 100, math.sin(angle) * 100,
				math.abs(love.math.randomNormal() * 5),
				math.abs(love.math.randomNormal() * 100)
			)
		end
	end

	table.insert(data.path, end_x)
	table.insert(data.path, end_y)

	data.x = end_x
	data.y = end_y
end

return id