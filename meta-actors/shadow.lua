---@type MetaActor
local def = {
    MAX_HP = 100,
    ATK = 15,
    DEF = 0,
    SPD = 200,
    name = "Fast Enemy",
    skills = {require "skills.attack"},
    image = love.graphics.newImage("assets/fast_enemy.png"),
    MAG = 0,
    STR = 10,
    alignment = {},
    weapon = WEAPON.NONE,
    weapon_mastery = 0
}

return def