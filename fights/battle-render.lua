
local draw_actor = require "ui.actor"

return function ()
	for key, value in ipairs(BATTLE) do
		if (value.visible) then
			draw_actor(value.x, value.y, value)
		end
	end

	--- draw battle order
	love.graphics.setFont(DEFAULT_FONT)
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.print("ACTION BAR", 0, 0)

	local offset_x = 20
	local offset_y = 20

	for key, value in ipairs(BATTLE) do
		if value.visible then
			love.graphics.setColor(1, 1, 1, 1)
			if (value.definition.image_action_bar) then
				love.graphics.draw(value.definition.image_action_bar, offset_x, offset_y, 0, 1, 1)
			else
				love.graphics.draw(value.definition.image, offset_x, offset_y, 0, 80 / ACTOR_WIDTH, 40 / ACTOR_HEIGHT)
			end
			love.graphics.setFont(DEFAULT_FONT)
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.print(tostring(value.action_number), offset_x + 80 + 2, offset_y + 2)
			love.graphics.rectangle("line", offset_x, offset_y, 80, 40)
			offset_y = offset_y + ACTOR_HEIGHT * 0.5 + 10
		end
	end
end