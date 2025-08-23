local style = require "ui._style"

local draw_actor = require "ui.actor"
local fill_rect = require "ui.fill-rect"
local draw_rect = require "ui.draw-rect"
local fill_image = require "ui.fill-image"

---@param battle Battle
return function (battle)
	for key, value in ipairs(battle.actors) do
		if (value.visible) then
			draw_actor.render(battle, value.x, value.y, value)
		end
	end

	--- draw battle order
	style.default_font()
	style.basic_element_color()

	love.graphics.line(style.base_margin, style.base_margin, style.base_margin, style.base_margin + 500)

	local offset_y = style.base_margin

	local first = true

	for key, value in ipairs(battle.actors) do
		if value.visible then
			local offset_x = style.base_margin + 15
			local height = style.action_bar_item_height
			local width = style.action_bar_item_width

			if first then
				offset_x = style.base_margin + 10
				height = style.action_bar_current_item_height
				width = style.action_bar_current_item_width
			else
				if value.team == 0 then
					love.graphics.circle("fill", style.base_margin, offset_y + height * 0.5, 3)
					love.graphics.line(
						style.base_margin, offset_y + height * 0.5,
						offset_x, offset_y + height * 0.5
					)
				else
					love.graphics.circle("fill", style.base_margin, offset_y + height * 0.5, 2)
				end
			end

			love.graphics.setColor(1, 1, 1, 1)
			if (value.definition.image_action_bar) then
				fill_image(
					value.definition.image_action_bar,
					offset_x,
					offset_y,
					width,
					height
				)
			else
				fill_image(
					value.definition.image,
					offset_x,
					offset_y,
					width,
					height
				)
			end

			if (not first) then
				love.graphics.setColor(1, 1, 1, 1)

				local action_value_width = 30
				local action_value_height = 20
				fill_rect(offset_x + width - action_value_width, offset_y + height - action_value_height, action_value_width, action_value_height)

				love.graphics.setColor(0, 0, 0, 1)
				style.default_font()
				love.graphics.printf(
					tostring(value.action_number),
					offset_x + width - action_value_width, offset_y + height - action_value_height,
					action_value_width, "center"
				)
			end

			love.graphics.setColor(0, 0, 0, 1)
			draw_rect(offset_x, offset_y, width, height)

			offset_y = offset_y + height + style.base_margin

			first = false
		end
	end
end