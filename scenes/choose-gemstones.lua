local manager = require "scenes._manager"
local style = require "ui._style"

local ids = require "scenes._ids"
local id = ids.gemstones
local def = manager.get(id)

local render_meta_actor = require "ui.meta-actor"
local gemstones = require "gemstones._manager"

local selected_actor_index = 1

local vertical_spacing = 30

function def.render(state)
	local row = 0
	local col = 0
	local cols = 3
	for index, value in ipairs(state.playable_actors) do
		local x = col * (ACTOR_WIDTH + 10) + 40
		local y = row * (ACTOR_HEIGHT + vertical_spacing) + 50
		if selected_actor_index == index then
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

	local x = 400
	local y = 20
	for _, value in ipairs(state.collected_gemstones) do
		local def = gemstones.get(value.def)
		love.graphics.rectangle("line", x, y, 200, 20)
		love.graphics.printf(def.name, x, y, 200, "center")

		love.graphics.rectangle("line", x + 210, y, 20, 20)
		love.graphics.printf("x", x + 210, y, 20, "center")

		if value.actor ~= 0 then
			local owner = state.playable_actors[value.actor]
			love.graphics.print(owner.def.name, x + 240, y)
		end
		y = y + 30
	end

	love.graphics.rectangle("line", 300, 50, 80, 30)
	love.graphics.printf("Return", 300, 50, 80, "center")
end

local rect = require "ui.rect"

function def.on_click(state, x, y)

	if rect(300, 50, 80, 30, x, y) then
		state.set_scene(state, ids.select_battle)
	end
	local row = 0
	local col = 0
	local cols = 3

	for index, value in ipairs(state.playable_actors) do
		if value.unlocked and rect(col * (ACTOR_WIDTH + 10) + 40, row * (ACTOR_HEIGHT + vertical_spacing) + 50, ACTOR_WIDTH, ACTOR_HEIGHT, x, y) then
			selected_actor_index = index
		end
		col = col + 1
		if col >= cols then
			row = row + 1
			col = 0
		end
	end

	local selected = state.playable_actors[selected_actor_index]
	local x_button = 400
	local y_button = 20
	for index, value in ipairs(state.collected_gemstones) do
		local def = gemstones.get(value.def)
		love.graphics.rectangle("line", x, y, 200, 20)
		if rect(x_button, y_button, 200, 20, x, y) then
			state.set_gemstone_owner(state, selected_actor_index, index)
		end

		if rect(x_button + 210, y_button, 20, 20, x, y) then
			state.set_gemstone_owner(state, 0, index)
		end

		y_button = y_button + 30
	end
end