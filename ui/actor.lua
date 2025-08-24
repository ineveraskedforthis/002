
local style = require "ui._style"
local fill_image = require "ui.fill-image"
local rect = require "ui.rect"

ACTOR_WIDTH = 50
ACTOR_HEIGHT = 70

local widget = {}

---@param colors table[]
local function gradient_h(colors)
	local result = love.image.newImageData(#colors, 1)
	for i, color in ipairs(colors) do
		local x, y = i - 1, 0
		print(x, y)
		result:setPixel(x, y, color[1], color[2], color[3], color[4] or 1)
	end
	local result_image = love.graphics.newImage(result)
	result_image:setFilter('linear', 'linear')
	return result_image
end

local function draw_image_in_rect(img, x, y, w, h, r, ox, oy, kx, ky)
	return love.graphics.draw(img, x, y, r, w / img:getWidth(), h / img:getHeight(), ox, oy, kx, ky)
end

local hp_gradient_ally = gradient_h({{0.7, 0.9, 0.8}, {100 / 255, 190 / 255, 175 / 255}})
local hp_gradient_enemy = gradient_h({{0.95, 0.1, 0.05}, {1, 0.11, 0.05}})

---comment
---@param x number
---@param y number
---@param w number
---@param h number
---@param hp number
---@param hp_view number
---@param max_hp number
---@param shield number
---@param team number
local function hp_bar(x, y, w, h, hp, hp_view, max_hp, shield, team)
	local outerouter = 1
	local outer = 1
	local shield_offset = 1
	local fill = 1
	local inner = 1

	-- outer outer border
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", x, y, w, h)

	-- outer border
	love.graphics.setColor(0.29, 0.35, 0.32)
	love.graphics.rectangle("fill", x + outerouter, y + outerouter, w - outerouter * 2, h - outerouter * 2)

	-- betweeen border fill
	love.graphics.setColor(0.4, 0.4, 0.4)
	love.graphics.rectangle("fill", x + outer + outerouter, y + outer + outerouter, w - (outer + outerouter) * 2, h - (outer + outerouter) * 2)

	-- shield
	local shield_ratio = math.min(1, shield / max_hp / 10)
	love.graphics.setColor(0.95, 0.95, 1)
	love.graphics.rectangle("fill", x + shield_offset, y + shield_offset, (w - shield_offset * 2) * shield_ratio, h - shield_offset * 2)

	-- inner border
	do
		love.graphics.setColor(0.1, 0.15, 0.1)
		local margin = outer + fill
		local _x = x + margin
		local _y = y + margin
		local _w = w - 2 * margin
		local _h = h - 2 * margin

		love.graphics.rectangle("fill", _x, _y, _w, _h)
	end

	-- hp bar
	do
		local hp_ratio_actual = hp / max_hp
		local hp_ratio_view = hp_view / max_hp
		local margin = outer + fill + inner
		local _x = x + margin
		local _y = y + margin
		local _w = w - 2 * margin
		local _h = h - 2 * margin
		love.graphics.setColor(1, 1, 1)
		if team == 1 then
			draw_image_in_rect(hp_gradient_enemy, _x, _y, _w * hp_ratio_actual, _h, 0)
		else
			draw_image_in_rect(hp_gradient_ally, _x, _y, _w * hp_ratio_actual, _h, 0)
		end

		if team == 1 then
			love.graphics.setColor(1, 0.8, 0.8, 1)
		else
			love.graphics.setColor(0.35, 0.45, 0.4)
		end

		if hp_ratio_view > hp_ratio_actual then
			love.graphics.rectangle("fill", _x + _w * hp_ratio_actual, _y, _w * (hp_ratio_view - hp_ratio_actual), _h)
		else
			love.graphics.rectangle("fill", _x + _w * hp_ratio_view, _y, _w * (hp_ratio_actual - hp_ratio_view), _h)
		end
	end
end

local function image_classic(battle, x, y, actor, alpha)
	if battle.selected_actor == actor then
		love.graphics.rectangle("line", x - 4, y - 4, ACTOR_WIDTH + 8, ACTOR_HEIGHT + 8)
	end
	love.graphics.setColor(0, 0, 0, alpha)
	style.default_font()
	love.graphics.printf(actor.definition.name, x - 10, y - 20, ACTOR_WIDTH + 20, "center")
	love.graphics.setColor(1, 1, 1, alpha)
	love.graphics.draw(actor.definition.image, x, y, 0)
	love.graphics.setColor(0, 0, 0, alpha)
	love.graphics.rectangle("line", x, y, ACTOR_WIDTH, ACTOR_HEIGHT)
end

---@type love.Quad[]
local quads = {}
---@type boolean[]
local quad_active = {}
---@type number[]
local quad_progress = {}

local scale = 1/4
local base_height = 320
local base_height_total = 500
local base_width = 500

for i = 1, 30 do
	quads[i] = love.graphics.newQuad(0, 0, 500, base_height, base_width, base_height_total)
	quad_active[i] = false
	quad_progress[i] = 0
end

---comment
---@param state GameState
---@param battle Battle
---@param x number
---@param y number
---@param actor Actor
function widget.render(state, battle, x, y, actor, alpha)
	local mouse_x, mouse_y = love.mouse.getPosition()
	if not alpha then
		alpha = 1
	end

	local max_hp = TOTAL_MAX_HP(actor.definition, actor.wrapper)

	local margin = 5

	if actor.definition.image_battle then
		local quad_index = actor.battle_id % 30 + 1

		local t = SMOOTHERSTEP(quad_progress[quad_index])
		local current_scale = scale + t * 1 / 12

		local actual_height = base_height_total * t + base_height * (1 - t)
		local offset_y = (base_height_total * current_scale - base_height * scale) * t
		local offset_x = (base_width * current_scale - base_width * scale) * t

		quads[quad_index]:setViewport(0, 0, base_width, actual_height, 500, 500)

		local source_ratio_y = 0.5
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(actor.definition.image_battle, quads[quad_index], x - offset_x, y - offset_y, 0, current_scale, current_scale)

		if actor.battle_order == 1 then
			quad_active[quad_index] = true
		else
			quad_active[quad_index] = false
		end

		hp_bar(
			x, y + base_height * scale, 500 * scale, 12,
			actor.HP, actor.HP_view or actor.HP, max_hp, actor.SHIELD,
			actor.team
		)
		love.graphics.setColor(0, 0, 0, alpha)
		style.header_font()
		if (actor.SHIELD > 0) then
			love.graphics.printf(tostring(math.floor(actor.HP)) .. " + " .. tostring(actor.SHIELD), x, y + base_height * scale - 30, ACTOR_WIDTH, "center")
		else
			love.graphics.printf(tostring(math.floor(actor.HP)), x, y + base_height * scale - 30, ACTOR_WIDTH, "center")
		end

		actor.w = base_width * scale
		actor.h = base_height * scale + 12
	else
		image_classic(battle, x, y, actor, alpha)
		local hp_bar_left = x - 8
		local hp_bar_width = ACTOR_WIDTH + 16
		hp_bar(
			hp_bar_left, y + ACTOR_HEIGHT + margin, hp_bar_width, 12,
			actor.HP, actor.HP_view or actor.HP, max_hp, actor.SHIELD,
			actor.team
		)
		love.graphics.setColor(0, 0, 0, alpha)
		if (actor.SHIELD > 0) then
			love.graphics.printf(tostring(math.floor(actor.HP)) .. " + " .. tostring(actor.SHIELD), x, y + ACTOR_HEIGHT + margin + 20, ACTOR_WIDTH, "center")
		else
			love.graphics.printf(tostring(math.floor(actor.HP)), x, y + ACTOR_HEIGHT + margin + 20, ACTOR_WIDTH, "center")
		end
	end

	for index, value in ipairs(actor.pending_damage) do
		if not value.particle_exist then
			local rgb = {1, 0, 0}
			if value.value <= 0 then
				rgb = {0, 1, 0}
			end
			state.vfx.new_text(
				tostring(math.abs(value.value)), rgb,
				x, y,
				love.math.randomNormal() * 20,
				-20,
				math.log(math.abs(value.value) + 1, 3),
				4
			)
			value.particle_exist = true
		end
	end
end


function widget.update(state, battle, dt)
	for index, value in ipairs(quad_active) do
		if value then
			quad_progress[index] = math.min(1, quad_progress[index] + dt)
		else
			quad_progress[index] = math.max(0, quad_progress[index] - dt)
		end
	end
end

---comment
---@param state GameState
---@param battle Battle
---@param x number
---@param y number
---@param actor Actor
---@return number
---@return number
---@return number
---@return number
function widget.get_rect(state, battle, x, y, actor)
	if actor.definition.image_battle and actor.battle_id ~= 0 then
		local t = SMOOTHERSTEP(quad_progress[actor.battle_id])
		local current_scale = scale + t * 1 / 12

		local actual_height = base_height_total * t + base_height * (1 - t)
		local offset_y = (base_height_total * current_scale - base_height * scale) * t
		local offset_x = (base_width * current_scale - base_width * scale) * t

		return x - offset_x, y - offset_y, current_scale * base_width, current_scale * actual_height + 12
	else
		return x, y, ACTOR_WIDTH, ACTOR_HEIGHT + 20
	end
end

return widget