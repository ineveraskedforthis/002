---@type MetaActor
local def = {
    MAX_HP = 120,
    ATK = 10,
    DEF = 0,
    SPD = 40,
    name = "Krist Wilfather",
    skills = {require "skills.attack"},
    image = love.graphics.newImage("assets/cris.png"),
    attack_sound = nil, --love.audio.newSource("ahhhh-gachi-muchi.mp3", "static"),
    damaged_sound = nil --love.audio.newSource("daxgasm.mp3", "static"),
}


return def