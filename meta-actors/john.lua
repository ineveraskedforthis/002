---@type MetaActor
local def = {
	MAX_HP = 3000,
	ATK = 20,
	DEF = 0,
	SPD = 120,
	name = "BOSS",
	inherent_skills = {require "skills.attack"},
	image = love.graphics.newImage("assets/jon.png"),
	MAG = 0,
	STR = 20,
	alignment = {},
	weapon = WEAPON.NONE,
	weapon_mastery = 0,
}

return def