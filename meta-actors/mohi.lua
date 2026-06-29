---@type MetaActor
local def = {
	MAX_HP = 100,
	STR = 5,
	MAG = 40,
	SPD = 110,
	alignment = {},
	weapon = WEAPON.NONE,
	weapon_mastery = 0,
	DEF = 0,
	name = "Mohi",
	inherent_skills = {require "skills.wait", require "skills.magic-arrow", require "skills.blood-spear"},
	image = love.graphics.newImage("assets/mohi.png"),
	image_battle = love.graphics.newImage("assets/mohi-square.png"),
	image_action_bar = love.graphics.newImage("assets/mohi-h.png"),
	STR_per_level = 0,
	MAG_per_level = 2,
	SPD_per_level = 1,
	max_energy = 5,
	gender = GENDER.FEMALE
}

def.alignment[ELEMENT.BLOOD] = true

return def