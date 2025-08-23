local manager = require "effects._manager"
local duration = 0.2
local id, def = manager.new_effect(duration)

local move_back = require "effects.move_to_original_position"

def.description = "Beam of energy jumps 10 times dealing 50% more damage at every step. Starting damage is [25% of MAG]."

function def.scene_render(state, battle, time_passed, origin, target, scene_data)
	---@type EnergyLinkData
	scene_data = scene_data

	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.setLineWidth(20)
	love.graphics.line(scene_data.path)

	local progress = SMOOTHERSTEP(time_passed / duration)
	love.graphics.setBlendMode("add")
	love.graphics.setColor(1, 1, 1, progress)
	love.graphics.setLineWidth(4)
	love.graphics.line(scene_data.path)
	love.graphics.setLineWidth(1)

	for index, value in ipairs(scene_data.additional_effects) do
		local x = target.x + math.cos(value.angle) * value.speed * progress
		local y = target.y + math.sin(value.angle) * value.speed * progress
		love.graphics.setColor(1, 1, 1, 0.4 * (1 - progress))
		love.graphics.circle("fill", x, y, value.size)
	end

	love.graphics.setBlendMode("alpha")
end

---@class EnergyLinkVFX
---@field angle number
---@field size number
---@field speed number

---@class EnergyLinkData
---@field damage number
---@field counter number
---@field additional_effects EnergyLinkVFX[]
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
		data.x = origin.x
		data.y = origin.y
		data.damage = TOTAL_MAG_ACTOR(origin) * 0.25
		data.additional_effects = {}
	else
		data.damage = data.damage * 1.5
		data.counter = data.counter - 1
	end

	data.path = {}

	-- generate 5 segments

	local start_x = data.x
	local start_y = data.y

	local end_x = target.x
	local end_y = target.y

	for i = 0, 5 do
		local t = i / 5
		table.insert(data.path, start_x * t + end_x * (1 - t) + love.math.randomNormal() * 5)
		table.insert(data.path, start_y * t + end_y * (1 - t) + love.math.randomNormal() * 5)
	end

	for i = 0, 500 do
		---@type EnergyLinkVFX
		local vfx = {
			angle = love.math.random() * math.pi * 2,
			size = math.abs(love.math.randomNormal() * 5),
			speed = math.abs(love.math.randomNormal() * 100)
		}
		table.insert(data.additional_effects, vfx)
	end

	data.x = end_x
	data.y = end_y
end

return id