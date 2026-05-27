local manager = require "scenes._manager"
local style = require "ui._style"

local ids = require "scenes._ids"
local id = ids.learning
local def = manager.get(id)


local render_meta_actor = require "ui.meta-actor"

local selected = 1

local vertical_spacing = 30

function def.render(state)
	local row = 0
	local col = 0
	local cols = 3

	for index, value in ipairs(state.playable_actors) do
		local x = col * (ACTOR_WIDTH + 10) + 40
		local y = row * (ACTOR_HEIGHT + vertical_spacing) + 50
		if selected == index then
			love.graphics.setColor(0.5, 0.5, 0, 1)
			love.graphics.rectangle("fill", x - 4, y - 4, ACTOR_WIDTH + 8, ACTOR_HEIGHT + 8)
		end
		render_meta_actor(x, y, value.def, value.unlocked, value.lineup_position)
		col = col + 1
		if col >= cols then
			row = row + 1
			col = 0
		end
	end

	local selected = state.playable_actors[selected]
	local x = 400
	local y = 20
	for _, value in ipairs(skills_to_learn) do
		if can_learn(value, selected) then
			love.graphics.rectangle("line", x, y, 200, 40)
			love.graphics.printf("Learn " .. value.name, x, y, 200, "center")
			love.graphics.printf("1 skill point, " .. tostring(value.cost) .. " points", x, y + 20, 200, "center")
			y = y + 50
		end
	end

	love.graphics.rectangle("line", 300, 50, 80, 30)
	love.graphics.printf("Return", 300, 50, 80, "center")

	love.graphics.printf("Current skill points: " .. selected.skill_points, 300, 80, 80, "center")

	love.graphics.printf("Known skills:", 300, 120, 80, "center")
	---@type number
	local y_skill = 140
	for _, value in ipairs(selected.skills) do
		love.graphics.printf(value.name, 280, y_skill, 100, "center")
		---@type number
		y_skill = y_skill + 20
	end
	for _, value in ipairs(selected.def.inherent_skills) do
		love.graphics.printf(value.name, 280, y_skill, 100, "center")
		---@type number
		y_skill = y_skill + 20
	end
end

local function update(dt)

end

local rect = require "ui.rect"

function def.on_click(state, x, y)

	if rect(300, 50, 80, 30, x, y) then
		state.set_scene(state, ids.location)
	end
	local row = 0
	local col = 0
	local cols = 3

	for index, value in ipairs(state.playable_actors) do
		if value.unlocked and rect(col * (ACTOR_WIDTH + 10) + 40, row * (ACTOR_HEIGHT + vertical_spacing) + 50, ACTOR_WIDTH, ACTOR_HEIGHT, x, y) then
			selected = index
		end
		col = col + 1
		if col >= cols then
			row = row + 1
			col = 0
		end
	end

	local selected = state.playable_actors[selected]
	local x_button = 400
	local y_button = 20
	for _, value in ipairs(skills_to_learn) do
		if can_learn(value, selected) then
			if rect(x_button, y_button, 200, 40, x, y) and selected.skill_points > 0 and state.currency >= value.cost then
				---@type number
				state.currency = state.currency - value.cost
				selected.skill_points = selected.skill_points - 1
				table.insert(selected.skills, value)
			end
			y_button = y_button + 50
		end
	end
end