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
SCENE_EDIT_LINEUP = 2

---@type MetaActorWrapper[]
PLAYABLE_META_ACTORS = {
    {
        def = require "meta-actors.main-character",
        unlocked = true,
        lineup_position = 1
    },
    {
        def = require "meta-actors.chud",
        unlocked = false,
        lineup_position = 0
    },
}

CHARACTER_LINEUP = {
    1,
    0,
    0,
    0
}

local scene_data_battle = require "scenes.battle"
local scene_data_battle_select = require "scenes.battle-select"
local scene_data_edit_lineup = require "scenes.edit-lineup"

function love.load()
    CURRENT_SCENE = SCENE_BATTLE_SELECTOR
end

function love.update(dt)
    if CURRENT_SCENE == SCENE_BATTLE then
        scene_data_battle.update(dt)
    elseif CURRENT_SCENE == SCENE_BATTLE_SELECTOR then
        scene_data_battle_select.update(dt)
    elseif CURRENT_SCENE == SCENE_EDIT_LINEUP then
        scene_data_edit_lineup.update(dt)
    end
end

function love.draw()
    if CURRENT_SCENE == SCENE_BATTLE then
        scene_data_battle.render()
    elseif CURRENT_SCENE == SCENE_BATTLE_SELECTOR then
        scene_data_battle_select.render()
    elseif CURRENT_SCENE == SCENE_EDIT_LINEUP then
        scene_data_edit_lineup.render()
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if CURRENT_SCENE == SCENE_BATTLE then
        scene_data_battle.on_click(x, y)
    elseif CURRENT_SCENE == SCENE_BATTLE_SELECTOR then
        scene_data_battle_select.on_click(x, y)
    elseif CURRENT_SCENE == SCENE_EDIT_LINEUP then
        scene_data_edit_lineup.on_click(x, y)
    end
end