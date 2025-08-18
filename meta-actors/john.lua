---@type MetaActor
local def = {
    MAX_HP = 3000,
    ATK = 20,
    DEF = 0,
    SPD = 120,
    name = "BOSS",
    skills = {require "skills.attack"},
    image = love.graphics.newImage("assets/jon.png"),
}

return def