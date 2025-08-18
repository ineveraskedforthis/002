require "fights._common"
require "mechanics.basic"

DEFAULT_FONT = love.graphics.newFont(
    "assets/Baskervville/static/Baskervville-Regular.ttf", 14
)
BIG_FONT = love.graphics.newFont(
    "assets/Baskervville/static/Baskervville-Bold.ttf", 28
)

SCENE_BATTLE_SELECTOR = 0
SCENE_BATTLE = 1

local scene_data_battle = require "scenes.battle"
local scene_data_battle_select = require "scenes.battle-select"

function love.load()
    CURRENT_SCENE = SCENE_BATTLE_SELECTOR
end

function love.update(dt)
    if CURRENT_SCENE == SCENE_BATTLE then
        scene_data_battle.update(dt)
    elseif CURRENT_SCENE == SCENE_BATTLE_SELECTOR then
        scene_data_battle_select.update(dt)
    end
end

function love.draw()
    if CURRENT_SCENE == SCENE_BATTLE then
        scene_data_battle.render()
    elseif CURRENT_SCENE == SCENE_BATTLE_SELECTOR then
        scene_data_battle_select.render()
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if CURRENT_SCENE == SCENE_BATTLE then
        scene_data_battle.on_click(x, y)
    elseif CURRENT_SCENE == SCENE_BATTLE_SELECTOR then
        scene_data_battle_select.on_click(x, y)
    end
end