---@type MetaActor
local def = {
    MAX_HP = 50,
    ATK = 40,
    DEF = 0,
    SPD = 120,
    name = "Hia",
    skills = {require "skills.heal-allies"},
    image = love.graphics.newImage("assets/hia.png"),
}

return def