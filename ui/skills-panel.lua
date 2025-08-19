local spacing = 50

---comment
---@param acting_actor Actor
---@param value ActiveSkill
local function render_skill(x, y, width, acting_actor, value)
	love.graphics.rectangle("line", x, y, 50, 20)
	love.graphics.setFont(DEFAULT_FONT)
	love.graphics.print("Use", x, y)

	-- prepare text
	local text = value.name .. "\n"
	text = text .. value.description(acting_actor) .. "\n"
	-- for index, effect in ipairs(value.effects_sequence) do
	-- 	text = text .. tostring(index) .. " ".. effect.description .. "\n"
	-- end
	love.graphics.printf(text, x, y + 20, width, "left")
end

local function render()
	-- draw character art on top
	local window_size = love.graphics.getWidth()
	local art_h = 100
	local width = 200

	local padding = 5
	local x = window_size - width - padding

	if BATTLE[1].team == 0 and SELECTED then
		local acting_actor = BATTLE[1]

		if (acting_actor.definition.image_skills) then
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.draw(acting_actor.definition.image_skills, x, padding)
		end

		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("line", x, 0 + padding, width, art_h)

		local offset_y = art_h + padding
		for key, value in ipairs(acting_actor.definition.inherent_skills) do
			render_skill(x, offset_y, width, acting_actor, value)
			offset_y = offset_y + spacing
		end
		if (acting_actor.wrapper) then
			for key, value in ipairs(acting_actor.wrapper.skills) do
				render_skill(x, offset_y, width, acting_actor, value)
				---@type number
				offset_y = offset_y + spacing
			end
		end
	end
end



local rect = require "ui.rect"
local function on_click(x, y)
	local window_size = love.graphics.getWidth()
	local art_h = 100
	local width = 200

	local padding = 5
	local _x = window_size - width - padding

	if BATTLE[1].team == 0 and SELECTED and AWAIT_TURN then
		local offset_y = art_h + padding

		local acting_actor = BATTLE[1]
		for key, value in ipairs(acting_actor.definition.inherent_skills) do
			if rect(_x, offset_y, 50, 20, x, y) then
				USE_SKILL(acting_actor, SELECTED, value)
				AWAIT_TURN = false
				return
			end
			offset_y = offset_y + spacing
		end

		if (acting_actor.wrapper) then
			for key, value in ipairs(acting_actor.wrapper.skills) do
				if rect(_x, offset_y, 50, 20, x, y) then
					USE_SKILL(acting_actor, SELECTED, value)
					AWAIT_TURN = false
					return
				end
				---@type number
				offset_y = offset_y + spacing
			end
		end
	end
end

return {
	render = render,
	on_click = on_click
}