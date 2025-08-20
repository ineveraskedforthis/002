---@type MetaActor
local def = {
	MAX_HP = 50,
	ATK = 40,
	DEF = 0,
	SPD = 110,
	name = "Chud",
	inherent_skills = {require "skills.wait", require "skills.attack"},
	image = love.graphics.newImage("assets/chud.png"),
	MAG = 10,
	STR = 10,
	alignment = {},
	weapon = WEAPON.NONE,
	weapon_mastery = 0,
	STR_per_level = 3,
	MAG_per_level = 3,
	SPD_per_level = 3,
}

def.alignment[ELEMENT.CHAOS] = true

return def