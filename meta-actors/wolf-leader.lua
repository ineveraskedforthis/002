---@type MetaActor
local def = {
    MAX_HP = 250,
    ATK = 10,
    DEF = 0,
    SPD = 250,
    name = "Wolf Leader",
    skills = {require "skills.shield-random-allies"},
    image = love.graphics.newImage("assets/wolf-leader.png"),
    attack_sound = nil,-- love.audio.newSource("ahhhh-gachi-muchi.mp3", "static"),
    damaged_sound = nil, --love.audio.newSource("daxgasm.mp3", "static"),
    MAG = 10,
    STR = 10,
    alignment = {},
    weapon = WEAPON.NONE,
    weapon_mastery = 0
}

return def