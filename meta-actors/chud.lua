---@type MetaActor
local def = {
	MAX_HP = 100,
	ATK = 40,
	DEF = 0,
	SPD = 110,
	name = "Chud",
	inherent_skills = {require "skills.wait", require "skills.magic-arrow", require "skills.attack"},
	image = love.graphics.newImage("assets/chud.png"),
	MAG = 20,
	STR = 5,
	alignment = {},
	weapon = WEAPON.NONE,
	weapon_mastery = 0,
	STR_per_level = 1,
	MAG_per_level = 1,
	SPD_per_level = 1,
	max_energy = 5,
	gender = GENDER.MALE
}

def.alignment[ELEMENT.CHAOS] = true

return def