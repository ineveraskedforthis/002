local spacing = 150

local function render()
    -- draw character art on top
    local window_size = love.graphics.getWidth()
    local art_h = 100
    local width = 200

    local padding = 5
    local x = window_size - width - padding

    love.graphics.rectangle("line", x, 0 + padding, width, art_h)

    if BATTLE[1].team == 0 and SELECTED then
        local offset_y = art_h + padding
        local acting_actor = BATTLE[1]
        for key, value in ipairs(acting_actor.definition.skills) do
            love.graphics.rectangle("line", x, offset_y, 50, 20)
            love.graphics.setFont(DEFAULT_FONT)
            love.graphics.print("Use", x, offset_y)

            -- prepare text
            local text = value.name .. "\n"
            text = text .. value.description(acting_actor) .. "\n"
            for index, effect in ipairs(value.effects_sequence) do
                text = text .. tostring(index) .. " ".. effect.description .. "\n"
            end
            love.graphics.printf(text, x, offset_y + 20, width, "left")
            offset_y = offset_y + spacing
        end
    end
end

local rect = require "ui.rect"
local function on_click(x, y)
    local window_size = love.graphics.getWidth()
    local art_h = 100
    local width = 200

    local padding = 5
    local _x = window_size - width - padding

    if BATTLE[1].team == 0 and SELECTED and AWAIT_TURN then
        local offset_y = art_h + padding

        local acting_actor = BATTLE[1]
        for key, value in ipairs(acting_actor.definition.skills) do
            if rect(_x, offset_y, 50, 20, x, y) then
                AWAIT_TURN = false
                -- ATTACK(ACTORS[BATTLE[1].actor_id], ACTORS[SELECTED])
                for index, effect in ipairs(value.effects_sequence) do
                    ---@type Effect
                    local new_effect = {
                        data = {},
                        def = effect,
                        origin = BATTLE[1],
                        target = SELECTED,
                        time_passed = 0,
                        started = false,
                        times_activated = 0
                    }
                    table.insert(EFFECTS_QUEUE, new_effect)
                end
                break
            end
            offset_y = offset_y + spacing
        end
    end
end

return {
    render = render,
    on_click = on_click
}