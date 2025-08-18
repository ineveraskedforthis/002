ACTOR_WIDTH = 50
ACTOR_HEIGHT = 70

---comment
---@param x number
---@param y number
---@param actor Actor
return function (x, y, actor)
    if SELECTED == actor then
        love.graphics.rectangle("line", x - 4, y - 4, ACTOR_WIDTH + 8, ACTOR_HEIGHT + 8)
    end
    love.graphics.setFont(DEFAULT_FONT)
    love.graphics.print(actor.definition.name, x, y - 20)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(actor.definition.image, x, y, 0)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("line", x, y, ACTOR_WIDTH, ACTOR_HEIGHT)

    if (actor.HP_view) then
        love.graphics.print(tostring(actor.HP_view) .. "/" .. tostring(actor.definition.MAX_HP), x, y + ACTOR_HEIGHT + 2)
    else
        love.graphics.print(tostring(actor.HP) .. "/" .. tostring(actor.definition.MAX_HP), x, y + ACTOR_HEIGHT + 2)
    end

    for index, value in ipairs(actor.pending_damage) do
        local a = value.alpha
        love.graphics.setColor(1, 0, 0, a)
        love.graphics.setFont(BIG_FONT)
        love.graphics.print(tostring(value.value), x, y - 50 * (1 - a))
    end
end