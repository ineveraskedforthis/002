local manager = require "scenes._manager"
local style = require "ui._style"
local scenes = require "scenes._ids"
local battle_manager = require "fights._battle-system"

local id = scenes.dialog
local def = manager.get(id)

local button = require "ui.button"
local panel = require "ui.panel"

local bg = love.graphics.newImage("assets/bg/default.jpg")

---comment
---@param state GameState
---@param render boolean
---@param click boolean
---@param mx number
---@param my number
local function interface(state, render, click, mx, my)
	if (state.current_dialog_actor == 0) then
		state.set_scene(state, scenes.location)
		return
	end

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(bg, 0, 0, 0, 1, 1)

	local actor = state.playable_actors[state.current_dialog_actor]

	local win_w, win_h, _ = love.window.getMode()
	love.graphics.draw(actor.def.image_battle, win_w - 500, win_h - 500)

	-- mockup

	panel(render, win_w / 2 - 200, win_h - 200, 400, 200 - style.base_margin)

	style.default_font_color()
	style.default_font()

	local atom = state.story_atoms[state.current_story_atom]
	local current_text  = atom.text(state, state.playable_actors[state.current_dialog_actor])
	love.graphics.printf(current_text, win_w / 2 - 200, win_h - 200 + style.base_margin, 400, "center")

	local options = atom.options(state, state.playable_actors[state.current_dialog_actor])

	local h = 50

	for index, value in ipairs(options) do
		local option_text = value.text(state, state.playable_actors[state.current_dialog_actor])
		if button(render, click, option_text, win_w / 2 - 200, h + index * 60, 400, 50, mx, my) then
			value.effect(state, state.playable_actors[state.current_dialog_actor])
		end
	end

	-- if button(render, click, "Gemstones", 800, 20, 80, 30, mx, my) then
		-- state.set_scene(state, scenes.gemstones)
	-- end
end

---comment
---@param state GameState
function def.render(state)
	local mx, my = love.mouse.getPosition();
	interface(state, true, false, mx, my)
end

---comment
---@param state GameState
---@param x number
---@param y number
function def.on_click(state, x, y)
	interface(state, false, true, x, y)
end