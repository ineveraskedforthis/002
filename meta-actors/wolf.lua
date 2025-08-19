---@type MetaActor
local def = {
    MAX_HP = 50,
    ATK = 10,
    DEF = 0,
    SPD = 150,
    name = "Wolf",
    skills = {require "skills.attack"},
    image = love.graphics.newImage("assets/wolf.png"),
    attack_sound = nil,-- love.audio.newSource("ahhhh-gachi-muchi.mp3", "static"),
    damaged_sound = nil, --love.audio.newSource("daxgasm.mp3", "static"),
    MAG = 0,
    STR = 5,
    alignment = {},
    weapon = WEAPON.NONE,
    weapon_mastery = 0
}

return def