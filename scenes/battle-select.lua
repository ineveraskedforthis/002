
local function enter()

end

local function update(dt)

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

local render_meta_actor = require "ui.meta-actor"

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

    --- render lineup

    for i = 1, 4 do
        if CHARACTER_LINEUP[i] ~= 0 then
            render_meta_actor(i * (ACTOR_WIDTH + 20) + 400, 400, PLAYABLE_META_ACTORS[CHARACTER_LINEUP[i]].def, true, i)
        else
            render_meta_actor(i * (ACTOR_WIDTH + 20) + 400, 400, nil, true, i)
        end
    end

    love.graphics.rectangle("line", 500, 500, 100, 20)
    love.graphics.print("pull", 500, 500)
end

local circle = require "ui.circle"
local rect = require "ui.rect"

local function handle_click(x, y)
    if rect(500, 500, 100, 20, x, y) then
        CURRENT_SCENE = SCENE_PULL_ACTORS
    end

    if circle(fight_1_x, fight_1_y, 50, x ,y) then
        WAVE = 1
        GENERATE_WAVE = require "fights.fight-1"
        GENERATE_WAVE()
        CURRENT_SCENE = SCENE_BATTLE
        AWAIT_TURN = true
    end

    for i = 1, 4 do
        if rect(i * (ACTOR_WIDTH + 20) + 400, 400, ACTOR_WIDTH, ACTOR_HEIGHT, x, y) then
            CURRENT_SCENE = SCENE_EDIT_LINEUP
            SELECTED_LINEUP_POSITION = i
        end
    end
end

local scene = {
    enter = enter,
    update = update,
    render = render,
    on_click = handle_click
}

return scene