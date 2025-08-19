---@type MetaActor
local def = {
	MAX_HP = 100,
	STR = 30,
	DEF = 0,
	SPD = 100,
	name = "Strong Enemy",
	skills = {require "skills.attack"},
	image = love.graphics.newImage("assets/strong_enemy.png"),
	attack_sound = nil,-- love.audio.newSource("ahhhh-gachi-muchi.mp3", "static"),
	damaged_sound = nil, --love.audio.newSource("daxgasm.mp3", "static"),
	MAG = 0,
	alignment = {},
	weapon = WEAPON.NONE,
	weapon_mastery = 0
}

return def