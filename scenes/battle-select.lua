local manager = require "scenes._manager"
local style = require "ui._style"

local ids = require "scenes._ids"
local id = ids.select_battle
local def = manager.get(id)

local widget_battle_selection = require "ui.battle-selection"
local render_meta_actor = require "ui.meta-actor"
local rect = require "ui.rect"

function def.render(state)
	style.basic_bg_color()
	widget_battle_selection.render(state)
	for i = 1, 4 do
		if state.current_lineup[i] ~= 0 then
			local wrapper = state.playable_actors[state.current_lineup[i]]
			render_meta_actor(i * (ACTOR_WIDTH + 20) + 400, 400, wrapper.def, true, i)
		else
			render_meta_actor(i * (ACTOR_WIDTH + 20) + 400, 400, nil, true, i)
		end
	end

	love.graphics.rectangle("line", 500, 500, 100, 20)
	love.graphics.printf("pull", 500, 500, 100, "center")

	love.graphics.rectangle("line", 600, 500, 100, 20)
	love.graphics.printf("learn", 600, 500, 100, "center")

	love.graphics.rectangle("line", 600, 520, 100, 20)
	love.graphics.printf("gems", 600, 520, 100, "center")
end


function def.on_click(state, x, y)
	widget_battle_selection.on_click(state, x, y)
	if rect(500, 500, 100, 20, x, y) then
		state.set_scene(state, ids.gacha)
	end

	if rect(600, 500, 100, 20, x, y) then
		state.set_scene(state, ids.learning)
	end

	if rect(600, 520, 100, 20, x, y) then
		state.set_scene(state, ids.gemstones)
	end

	for i = 1, 4 do
		if rect(i * (ACTOR_WIDTH + 20) + 400, 400, ACTOR_WIDTH, ACTOR_HEIGHT, x, y) then
			state.selected_lineup_position = i
			state.set_scene(state, ids.lineup)
		end
	end
end