local manager = require "scenes._manager"
local style = require "ui._style"

local ids = require "scenes._ids"
local id = ids.lineup
local def = manager.get(id)

local render_meta_actor = require "ui.meta-actor"

function def.render(state)
	local row = 0
	local col = 0
	local cols = 4

	for index, value in ipairs(state.playable_actors) do
		render_meta_actor(col * (ACTOR_WIDTH + 10) + 40, row * (ACTOR_HEIGHT + 10) + 50, value.def, value.unlocked, value.lineup_position)
		col = col + 1
		if col >= cols then
			row = row + 1
			col = 0
		end
	end
end

local function update(dt)

end

local rect = require "ui.rect"

function def.on_click(state, x, y)
	local row = 0
	local col = 0
	local cols = 4

	for index, value in ipairs(state.playable_actors) do
		if value.unlocked and rect(col * (ACTOR_WIDTH + 10) + 40, row * (ACTOR_HEIGHT + 10) + 50, ACTOR_WIDTH, ACTOR_WIDTH, x, y) then
			local old_actor = state.playable_actors[state.current_lineup[state.selected_lineup_position]]
			if old_actor then
				old_actor.lineup_position = 0
			end
			state.current_lineup[state.selected_lineup_position] = index
			if (value.lineup_position ~= 0) then
				state.current_lineup[value.lineup_position] = 0
			end
			value.lineup_position = state.selected_lineup_position

			state.set_scene(state, ids.select_battle)
		end
		col = col + 1
		if col >= cols then
			row = row + 1
			col = 0
		end
	end
end