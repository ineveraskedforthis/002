local style = require "ui._style"

local max_particles = 500
local current_available_id = 1

local max_text_particles = 50
local current_available_text_id = 1

local clear = require "table.clear"
---@class ManagerVFX
---@field particle_x number[]
---@field particle_y number[]
---@field particle_vx number[]
---@field particle_vy number[]
---@field particle_size number[]
---@field particle_lifetime number[]
---@field particle_max_lifetime number[]
---@field text_string string[]
---@field text_x number[]
---@field text_y number[]
---@field text_size number[]
---@field text_vx number[]
---@field text_vy number[]
---@field text_rgb number[][]
---@field text_lifetime number[]
---@field text_max_lifetime number[]
local manager = {
	particle_max_lifetime = {},
	particle_lifetime = {},
	particle_size = {},
	particle_vx = {},
	particle_vy = {},
	particle_x = {},
	particle_y = {},
	text_string = {},
	text_x = {},
	text_y = {},
	text_size = {},
	text_vx = {},
	text_vy = {},
	text_lifetime = {},
	text_max_lifetime = {},
	text_rgb = {}
}

function manager.clear()
	for i = 1, max_particles do
		manager.particle_max_lifetime[i] = 0
		manager.particle_lifetime[i] = 0
		manager.particle_size[i] = 0
		manager.particle_vx[i] = 0
		manager.particle_vy[i] = 0
		manager.particle_x[i] = 0
		manager.particle_y[i] = 0
	end

	for i = 1, max_text_particles do
		manager.text_max_lifetime[i] = 0
		manager.text_lifetime[i] = 0
		manager.text_size[i] = 0
		manager.text_vx[i] = 0
		manager.text_vy[i] = 0
		manager.text_x[i] = 0
		manager.text_y[i] = 0
		manager.text_rgb[i] = {1, 1, 1}
	end
end

manager.clear()

function manager.new_particle(x, y, vx, vy, size, max_lifetime)
	local i = current_available_id
	current_available_id = (current_available_id + 1) % max_particles + 1

	manager.particle_max_lifetime[i] = max_lifetime
	manager.particle_lifetime[i] = 0
	manager.particle_size[i] = size
	manager.particle_vx[i] = vx
	manager.particle_vy[i] = vy
	manager.particle_x[i] = x
	manager.particle_y[i] = y
end


function manager.new_text(text, rgb, x, y, vx, vy, size, max_lifetime)
	local i = current_available_text_id
	current_available_text_id = (current_available_text_id + 1) % max_text_particles + 1

	manager.text_lifetime[i] = 0
	manager.text_rgb[i] = rgb
	manager.text_max_lifetime[i] = max_lifetime
	manager.text_size[i] = size
	manager.text_string[i] = text
	manager.text_vx[i] = vx
	manager.text_vy[i] = vy
	manager.text_x[i] = x
	manager.text_y[i] = y
end


---@param dt number
function manager.update(dt)
	local decay = math.exp(-dt)
	for index, lifetime in ipairs(manager.particle_lifetime) do
		manager.particle_x[index] = manager.particle_x[index] + manager.particle_vx[index] * dt
		manager.particle_y[index] = manager.particle_y[index] + manager.particle_vy[index] * dt
		manager.particle_lifetime[index] = manager.particle_lifetime[index] + dt
		manager.particle_size[index] = manager.particle_size[index] * decay
	end

	for index, lifetime in ipairs(manager.text_lifetime) do
		manager.text_x[index] = manager.text_x[index] + manager.text_vx[index] * dt
		manager.text_y[index] = manager.text_y[index] + manager.text_vy[index] * dt
		manager.text_lifetime[index] = manager.text_lifetime[index] + dt
	end
end

function manager.render()
	love.graphics.setBlendMode("add")

	for i, lifetime in ipairs(manager.particle_lifetime) do
		if lifetime < manager.particle_max_lifetime[i] then
			love.graphics.setColor(1, 1, 1, 1 - lifetime / manager.particle_max_lifetime[i])
			love.graphics.circle("fill", manager.particle_x[i], manager.particle_y[i], manager.particle_size[i])
		end
	end

	love.graphics.setBlendMode("alpha")

	for i, lifetime in ipairs(manager.text_lifetime) do
		if lifetime < manager.text_max_lifetime[i] then
			style.font(manager.text_size[i])

			local text = manager.text_string[i]
			local x = manager.text_x[i]
			local y = manager.text_y[i]
			local a = 1 - SMOOTHERSTEP(lifetime / manager.text_max_lifetime[i])

			love.graphics.setColor(0, 0, 0, a)
			local text_border = 1
			love.graphics.print(text, x - text_border, y)
			love.graphics.print(text, x, y + text_border)
			love.graphics.print(text, x + text_border, y)
			love.graphics.print(text, x, y - text_border)
			love.graphics.setColor(
				manager.text_rgb[i][1], manager.text_rgb[i][2], manager.text_rgb[i][3], a
			)
			love.graphics.print(text, x, y)
		end
	end
end

return manager

