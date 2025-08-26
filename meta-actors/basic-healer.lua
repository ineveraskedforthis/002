---@type MetaActor
local def = {
	MAX_HP = 100,
	MAG = 20,
	alignment = {},
	weapon = WEAPON.NONE,
	weapon_mastery = 0,
	max_energy = 5,
	STR = 3,
	DEF = 0,
	SPD = 120,
	name = "Hia",
	inherent_skills = {require "skills.wait", require "skills.magic-arrow"},
	image = love.graphics.newImage("assets/hia.png"),
	STR_per_level = 1,
	MAG_per_level = 1,
	SPD_per_level = 1,
}

def.alignment[ELEMENT.RESTORATION] = true

return def