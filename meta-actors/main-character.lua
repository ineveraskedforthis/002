---@type MetaActor
local def = {
    MAX_HP = 100,
    ATK = 50,
    DEF = 0,
    SPD = 100,
    name = "(You)",
    skills = {require "skills.attack", require "skills.heavy-strike"},
    image = love.graphics.newImage("assets/main-character.png"),
    image_action_bar = love.graphics.newImage("assets/main-character-h.png"),
    image_skills = love.graphics.newImage("assets/main-character-skills.png"),
}

return def