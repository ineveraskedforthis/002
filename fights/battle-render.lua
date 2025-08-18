
local draw_actor = require "ui.actor"


local get_x = require "ui.battle".get_x
local get_y = require "ui.battle".get_y

return function (attacker, target)
    for key, value in ipairs(BATTLE) do
        local x = get_x(value)
        local y = get_y(value)

        local draw_normally = true
        if attacker == value or target == value then
            draw_normally = false
        end

        if draw_normally then
            draw_actor(x, y, value)
        end
    end

    --- draw battle order
    love.graphics.setFont(DEFAULT_FONT)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print("ACTION BAR", 0, 0)

    local offset_x = 20
    local offset_y = 20

    for key, value in ipairs(BATTLE) do
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(value.definition.image, offset_x, offset_y, 0, 1.5, 0.5)
        love.graphics.setFont(DEFAULT_FONT)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.print(tostring(value.action_number), offset_x + ACTOR_WIDTH * 1.5 + 2, offset_y + 2)
        love.graphics.rectangle("line", offset_x, offset_y, ACTOR_WIDTH * 1.5, ACTOR_HEIGHT * 0.5)
        offset_y = offset_y + ACTOR_HEIGHT * 0.5 + 10
    end
end