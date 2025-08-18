
local function enter()

end

local function update()

end

local spacing = 150

local fight_1_x = 150
local fight_1_y = 300

local fight_2_x = fight_1_x + spacing
local fight_2_y = 350

local fight_3_x = fight_2_x + spacing
local fight_3_y = 250

local fight_4_x = fight_3_x + spacing
local fight_4_y = 300

local function render()
    love.graphics.setBackgroundColor(1, 1, 1, 1)
    love.graphics.setColor(0, 0, 0, 1)

    love.graphics.circle("line", fight_1_x, fight_1_y, 50)
    love.graphics.print("Enter battle 1", fight_1_x - 40, fight_1_y - 10)

    love.graphics.circle("line", fight_2_x, fight_2_y, 50)
    love.graphics.print("Enter battle 2", fight_2_x - 40, fight_2_y - 10)

    love.graphics.circle("line", fight_3_x, fight_3_y, 50)
    love.graphics.print("Enter battle 3", fight_3_x - 40, fight_3_y - 10)

    love.graphics.circle("line", fight_4_x, fight_4_y, 50)
    love.graphics.print("Enter battle 4", fight_4_x - 40, fight_4_y - 10)
end

local circle = require "ui.circle"

local function handle_click(x, y)
    if circle(fight_1_x, fight_1_y, 50, x ,y) then
        WAVE = 1
        GENERATE_WAVE = require "fights.fight-1"
        GENERATE_WAVE()
        CURRENT_SCENE = SCENE_BATTLE
    end
end

local scene = {
    enter = enter,
    update = update,
    render = render,
    on_click = handle_click
}

return scene