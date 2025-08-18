
local render_meta_actor = require "ui.meta-actor"

local function render()
    local row = 0
    local col = 0
    local cols = 4

    for index, value in ipairs(PLAYABLE_META_ACTORS) do
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

local function handle_click(x, y)
    local row = 0
    local col = 0
    local cols = 4

    for index, value in ipairs(PLAYABLE_META_ACTORS) do
        if rect(col * (ACTOR_WIDTH + 10) + 40, row * (ACTOR_HEIGHT + 10) + 50, ACTOR_WIDTH, ACTOR_WIDTH, x, y) then
            local old_actor = PLAYABLE_META_ACTORS[CHARACTER_LINEUP[SELECTED_LINEUP_POSITION]]
            if old_actor then
                old_actor.lineup_position = 0
            end
            CHARACTER_LINEUP[SELECTED_LINEUP_POSITION] = index
            if (value.lineup_position ~= 0) then
                CHARACTER_LINEUP[value.lineup_position] = 0
            end
            value.lineup_position = SELECTED_LINEUP_POSITION

            CURRENT_SCENE = SCENE_BATTLE_SELECTOR
        end
        col = col + 1
        if col >= cols then
            row = row + 1
            col = 0
        end
    end
end

local scene = {
    update = update,
    render = render,
    on_click = handle_click
}

return scene