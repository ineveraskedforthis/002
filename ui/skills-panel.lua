local effects = require "effects._manager"

local STAGE = require "fights._stages"

local style = require "ui._style"
local rect = require "ui.rect"
local fill_image = require "ui.fill-image"
local fill_rect = require "ui.fill-rect"
local draw_rect = require "ui.draw-rect"


local offset_x = style.action_bar_item_width * 2
local description_offset_x = 200
local description_offset_y = 200

local internal_timer = 0
---@type number[]
local transition = {}
---@type boolean[]
local active_cells = {}

for i = 0, 100 do
	transition[i] = 0
	active_cells[i] = false
end

---comment
---@param x number
---@param y number
---@param width number
---@param acting_actor Actor
---@param value ActiveSkill
local function render_skill(x, y, width, acting_actor, value)
	local window_size = love.graphics.getWidth()

	local true_size = style.skill_button_size - style.base_margin * 2
	local true_x = x + style.base_margin
	local true_y = y + style.base_margin
	local m_x, m_y = love.mouse.getPosition()

	local hovered = false

	if value.icon then
		fill_image(value.icon, true_x, true_y, true_size, true_size)
	else
		love.graphics.rectangle("line", true_x, true_y, true_size, true_size)
		style.default_font()
		love.graphics.printf(value.name, true_x, true_y, true_size, "center")
	end

	if rect(true_x, true_y, true_size, true_size, m_x, m_y) then
		hovered = true
		local text = value.name .. "\n"
		text = text .. value.description(acting_actor) .. "\n"
		for index, effect in ipairs(value.effects_sequence) do
			local effect_def = effects.get(effect)
			text = text .. tostring(index) .. " ".. effect_def.description .. "\n"
		end
		love.graphics.printf(text, window_size - description_offset_x, description_offset_y, description_offset_x - style.base_margin, "left")
	end

	return hovered
end

---comment
---@param battle BattleState
local function render(battle)
	-- draw character art on top
	local window_size = love.graphics.getWidth()
	local window_h = love.graphics.getHeight()
	local art_h = 100
	local width = 200

	local padding = 5
	local x = window_size - width - padding

	if battle.actors[1] and battle.actors[1].team == 0 and battle.selected_actor then
		local acting_actor = battle.actors[1]
		if (acting_actor.definition.image_skills) then
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.draw(acting_actor.definition.image_skills, x, padding)
		end

		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("line", x, 0 + padding, width, art_h)

		local reserve_points = 0

		do
			local offset_y = style.skill_button_size + style.base_margin
			local current_x = offset_x
			for key, value in ipairs(acting_actor.definition.inherent_skills) do
				if render_skill(current_x, window_h - offset_y, width, acting_actor, value) then
					reserve_points = value.required_energy
				end
				current_x = current_x + style.skill_button_size
			end
			if (acting_actor.wrapper) then
				for key, value in ipairs(acting_actor.wrapper.skills) do
					if render_skill(current_x, window_h - offset_y, width, acting_actor, value) then
						reserve_points = value.required_energy
					end
					---@type number
					current_x = current_x + style.skill_button_size
				end
			end
		end

		-- draw energy points
		do
			local current_x = offset_x
			local current_y = window_h - style.skill_button_size - style.base_margin - style.energy_point_h - style.base_margin

			for i = 1, 20 do
				local shrink = 0
				local shift_y = 0
				local fill = false

				local shift = math.max(0, acting_actor.energy - reserve_points)

				local reserved = i > shift and i - shift <= reserve_points
				local current = i <= acting_actor.energy

				local t = SMOOTHERSTEP(transition[i])

				local r = 0.2
				local g = 0.8
				local b = 1

				love.graphics.setColor(r, g, b, 1)

				if reserved and current then
					fill = true
					active_cells[i] = true
				elseif reserved then
					fill = false
					active_cells[i] = true
				elseif current then
					fill = true
					active_cells[i] = false
				else
					love.graphics.setColor(0, 0, 0, 1)
					fill = false
					active_cells[i] = false
				end

				shrink = 5 * t
				shift_y = -3 * (4 + math.cos(internal_timer * 2 + i / 2)) * t

				if fill then
					fill_rect(
						current_x,
						current_y+ shift_y,
						style.energy_point_w,
						style.energy_point_h
					)

					if shrink > 0 then


						love.graphics.setColor(r * (1 - t), g * (1 - t) + 0.1 * t, b * (1 - t) + 0.5 * t, 1)
						fill_rect(
							current_x + shrink,
							current_y+ shift_y + shrink,
							style.energy_point_w - shrink * 2,
							style.energy_point_h - shrink * 2
						)
					end
				end

				love.graphics.setColor(0, 0, 0, 1)

				draw_rect(
					current_x,
					current_y + shift_y,
					style.energy_point_w,
					style.energy_point_h
				)

				current_x = current_x + style.energy_point_w + style.base_margin
			end
		end
	end

end

---comment
---@param state GameState
---@param battle BattleState
---@param x number
---@param y number
local function on_click(state, battle, x, y)
	local window_size = love.graphics.getWidth()
	local window_h = love.graphics.getHeight()
	local art_h = 100
	local width = 200

	local padding = 5
	local _x = window_size - width - padding

	if battle.actors[1].team == 0 and battle.selected_actor and battle.stage == STAGE.AWAIT_TURN then
		local offset_y = style.skill_button_size + style.base_margin
		local current_x = offset_x
		local true_size = style.skill_button_size - style.base_margin * 2

		local acting_actor = battle.actors[1]
		for key, value in ipairs(acting_actor.definition.inherent_skills) do
			local can_use = CAN_USE_SKILL(state, battle, acting_actor, battle.selected_actor, value)
			if rect(current_x + style.base_margin, window_h - offset_y + style.base_margin, true_size, true_size, x, y) and can_use then
				USE_SKILL(state, battle, acting_actor, battle.selected_actor, value)
				battle.stage = STAGE.PROCESS_EFFECTS_AFTER_TURN
				return
			end
			current_x = current_x + style.skill_button_size
		end

		if (acting_actor.wrapper) then
			for key, value in ipairs(acting_actor.wrapper.skills) do
				local can_use = CAN_USE_SKILL(state, battle, acting_actor, battle.selected_actor, value)
				if rect(current_x + style.base_margin, window_h - offset_y + style.base_margin, true_size, true_size, x, y) and can_use then
					USE_SKILL(state, battle, acting_actor, battle.selected_actor, value)
					battle.stage = STAGE.PROCESS_EFFECTS_AFTER_TURN
					return
				end
				---@type number
				current_x = current_x + style.skill_button_size
			end
		end
	end
end

return {
	render = render,
	on_click = on_click,
	update = function (state, dt)
		---@type number
		internal_timer = internal_timer + dt

		for index, value in ipairs(transition) do
			if active_cells[index] then
				transition[index] = math.min(1, transition[index] + dt)
			else
				transition[index] = math.max(0, transition[index] - dt)
			end
		end
	end
}