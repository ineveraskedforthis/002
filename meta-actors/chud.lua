---@type MetaActor
local def = {
    MAX_HP = 50,
    ATK = 40,
    DEF = 0,
    SPD = 120,
    name = "Chud",
    skills = {require "skills.poison-strike"},
    image = love.graphics.newImage("assets/chud.png"),
}

return def