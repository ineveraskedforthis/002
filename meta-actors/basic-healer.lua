---@type MetaActor
local def = {
	MAX_HP = 50,
	MAG = 20,
	alignment = {},
	weapon = WEAPON.NONE,
	weapon_mastery = 0,
	STR = 4,
	DEF = 0,
	SPD = 120,
	name = "Hia",
	inherent_skills = {require "skills.wait"},
	image = love.graphics.newImage("assets/hia.png"),
}

def.alignment[ELEMENT.RESTORATION] = true

return def