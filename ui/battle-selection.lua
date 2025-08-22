local scenes = require "scenes._ids"

local style = require "ui._style"
local circle = require "ui.circle"

local start_scripted_battle = require "fights._loader"
local BATTLES = require "fights._enum"

local spacing = 150

local fight_easy_1_x = 100
local fight_easy_1_y = 120
local fight_1_x = 150
local fight_1_y = 300
local fight_2_x = fight_1_x + spacing
local fight_2_y = 350
local fight_3_x = fight_2_x + spacing
local fight_3_y = 250
local fight_4_x = fight_3_x + spacing
local fight_4_y = 300

local widget = {}

---comment
---@param state GameState
function widget.render(state)
	style.basic_element_color()

	love.graphics.circle("line", fight_easy_1_x, fight_easy_1_y, 50)
	love.graphics.printf("Enter easy battle 1", fight_easy_1_x - 40, fight_easy_1_y - 10, 80, "center")

	love.graphics.circle("line", fight_1_x, fight_1_y, 50)
	love.graphics.print("Enter battle 1", fight_1_x - 40, fight_1_y - 10)

	love.graphics.circle("line", fight_2_x, fight_2_y, 50)
	love.graphics.print("Enter battle 2", fight_2_x - 40, fight_2_y - 10)

	love.graphics.circle("line", fight_3_x, fight_3_y, 50)
	love.graphics.print("Enter battle 3", fight_3_x - 40, fight_3_y - 10)

	love.graphics.circle("line", fight_4_x, fight_4_y, 50)
	love.graphics.print("Enter battle 4", fight_4_x - 40, fight_4_y - 10)
end

---comment
---@param state GameState
---@param x number
---@param y number
function widget.on_click(state, x, y)
	if circle(fight_easy_1_x, fight_easy_1_y, 50, x ,y) then
		start_scripted_battle(state, BATTLES.EASY_1)
		state.set_scene(state, scenes.battle)
	end

	if circle(fight_1_x, fight_1_y, 50, x ,y) then
		start_scripted_battle(state, BATTLES.NORMAL_1)
		state.set_scene(state, scenes.battle)
	end

	if circle(fight_2_x, fight_2_y, 50, x ,y) then
		start_scripted_battle(state, BATTLES.NORMAL_2)
		state.set_scene(state, scenes.battle)
	end
end


return widget