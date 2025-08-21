---@type MetaActor
local def = {
	MAX_HP = 300,
	MAG = 40,
	alignment = {},
	weapon = WEAPON.NONE,
	weapon_mastery = 0,
	STR = 5,
	DEF = 0,
	SPD = 110,
	name = "Mohi",
	inherent_skills = {require "skills.wait", require "skills.magic-arrow", require "skills.blood-spear"},
	image = love.graphics.newImage("assets/mohi.png"),
	image_action_bar = love.graphics.newImage("assets/mohi-h.png"),
	STR_per_level = 1,
	MAG_per_level = 6,
	SPD_per_level = 4,
}

def.alignment[ELEMENT.BLOOD] = true

return def