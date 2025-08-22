local STAGE = require "state.battle".BATTLE_STAGE

local style = require "ui._style"
local spacing = 50

---comment
---@param acting_actor Actor
---@param value ActiveSkill
local function render_skill(x, y, width, acting_actor, value)
	love.graphics.rectangle("line", x, y, 50, 20)
	style.default_font()
	love.graphics.print("Use", x, y)

	-- prepare text
	local text = value.name .. "\n"
	text = text .. value.description(acting_actor) .. "\n"
	-- for index, effect in ipairs(value.effects_sequence) do
	-- 	text = text .. tostring(index) .. " ".. effect.description .. "\n"
	-- end
	love.graphics.printf(text, x, y + 20, width, "left")
end

---comment
---@param battle Battle
local function render(battle)
	-- draw character art on top
	local window_size = love.graphics.getWidth()
	local art_h = 100
	local width = 200

	local padding = 5
	local x = window_size - width - padding

	if battle.actors[1].team == 0 and battle.selected_actor then
		local acting_actor = battle.actors[1]
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

---comment
---@param state GameState
---@param battle Battle
---@param x number
---@param y number
local function on_click(state, battle, x, y)
	local window_size = love.graphics.getWidth()
	local art_h = 100
	local width = 200

	local padding = 5
	local _x = window_size - width - padding

	if battle.actors[1].team == 0 and battle.selected_actor and battle.stage == STAGE.AWAIT_TURN then
		local offset_y = art_h + padding

		local acting_actor = battle.actors[1]
		for key, value in ipairs(acting_actor.definition.inherent_skills) do
			if rect(_x, offset_y, 50, 20, x, y) then
				USE_SKILL(state, battle, acting_actor, battle.selected_actor, value)
				battle.stage = STAGE.PROCESS_EFFECTS_AFTER_TURN
				return
			end
			offset_y = offset_y + spacing
		end

		if (acting_actor.wrapper) then
			for key, value in ipairs(acting_actor.wrapper.skills) do
				if rect(_x, offset_y, 50, 20, x, y) then
					USE_SKILL(state, battle, acting_actor, battle.selected_actor, value)
					battle.stage = STAGE.PROCESS_EFFECTS_AFTER_TURN
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