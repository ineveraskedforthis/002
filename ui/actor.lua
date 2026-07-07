
local style = require "ui._style"
local fill_image = require "ui.fill-image"
local rect = require "ui.rect"

ACTOR_WIDTH = 50
ACTOR_HEIGHT = 70

local widget = {}

local function image_classic(x, y, actor, alpha)
	-- if state.selected_actor == actor then
		-- love.graphics.rectangle("line", x - 4, y - 4, ACTOR_WIDTH + 8, ACTOR_HEIGHT + 8)
	-- end
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
---@param x number
---@param y number
---@param actor_index number
---@param alpha number
---@param hostile boolean
function widget.render(state, x, y, actor_index, alpha, hostile)
	local mouse_x, mouse_y = love.mouse.getPosition()
	if not alpha then
		alpha = 1
	end

	local actor = state.actors[actor_index]

	local max_hp = TOTAL_MAX_HP(actor.definition, actor.wrapper)

	local margin = 5

	if actor.definition.image_battle then
		local quad_index = actor_index % 30 + 1

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

		local level = nil

		if actor.wrapper then
			level = actor.wrapper.level
		end

		hp_bar(
			x, y + base_height * scale, 500 * scale, 12,
			actor.HP, actor.HP_view or actor.HP, max_hp, actor.SHIELD,
			hostile, level
		)
		style.header_font()
		local ty = y + base_height * scale - 60
		if (actor.SHIELD > 0) then
			local text = tostring(math.floor(actor.HP)) .. " + " .. tostring(actor.SHIELD)
			love.graphics.setColor(1, 1, 1, alpha)
			love.graphics.printf(text, x-1, ty, ACTOR_WIDTH, "center")
			love.graphics.printf(text, x+1, ty, ACTOR_WIDTH, "center")
			love.graphics.printf(text, x, ty-1, ACTOR_WIDTH, "center")
			love.graphics.printf(text, x, ty+1, ACTOR_WIDTH, "center")
			love.graphics.setColor(0, 0, 0, alpha)
			love.graphics.printf(text, x, ty, ACTOR_WIDTH, "center")
		else
			local text = tostring(math.floor(actor.HP))
			love.graphics.setColor(1, 1, 1, alpha)
			love.graphics.printf(text, x-1, ty, ACTOR_WIDTH, "center")
			love.graphics.printf(text, x+1, ty, ACTOR_WIDTH, "center")
			love.graphics.printf(text, x, ty-1, ACTOR_WIDTH, "center")
			love.graphics.printf(text, x, ty+1, ACTOR_WIDTH, "center")
			love.graphics.setColor(0, 0, 0, alpha)
			love.graphics.printf(text, x, y + base_height * scale - 60, ACTOR_WIDTH, "center")
		end

		actor.w = base_width * scale
		actor.h = base_height * scale + 12
	else
		image_classic(x, y, actor, alpha)
		local hp_bar_left = x - 8
		local hp_bar_width = ACTOR_WIDTH + 16
		hp_bar(
			hp_bar_left, y + ACTOR_HEIGHT + margin, hp_bar_width, 12,
			actor.HP, actor.HP_view or actor.HP, max_hp, actor.SHIELD,
			hostile
		)
		love.graphics.setColor(0, 0, 0, alpha)
		if (actor.SHIELD > 0) then
			love.graphics.printf(tostring(math.floor(actor.HP)) .. " + " .. tostring(actor.SHIELD), x, y + ACTOR_HEIGHT + margin + 20, ACTOR_WIDTH, "center")
		else
			love.graphics.printf(tostring(math.floor(actor.HP)), x, y + ACTOR_HEIGHT + margin + 20, ACTOR_WIDTH, "center")
		end
	end

end


function widget.update(dt)
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
---@param battle BattleState
---@param x number
---@param y number
---@param actor_index number
---@return number
---@return number
---@return number
---@return number
function widget.get_rect(state, battle, x, y, actor_index)
	local actor = state.actors[actor_index]
	local quad_index = actor_index % 30 + 1
	if actor.definition.image_battle then
		local t = SMOOTHERSTEP(quad_progress[quad_index])
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