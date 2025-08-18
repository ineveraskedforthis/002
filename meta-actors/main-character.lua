---@type MetaActor
local def = {
    MAX_HP = 100,
    ATK = 50,
    DEF = 0,
    SPD = 100,
    name = "(You)",
    skills = {require "skills.attack", require "skills.heavy-strike"},
    image = love.graphics.newImage("assets/gg.png"),
}

return def