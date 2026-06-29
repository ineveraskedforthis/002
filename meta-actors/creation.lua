---@type MetaActor
local def = {
	MAX_HP = 4000,
	DEF = 30,
	SPD = 130,
	name = "Creation",
	inherent_skills = {require "skills.attack"},
	image = love.graphics.newImage("assets/creation.png"),
	image_action_bar = love.graphics.newImage("assets/creation-h.png"),
	image_battle = love.graphics.newImage("assets/creation-square.png"),
	MAG = 0,
	STR = 25,
	alignment = {},
	weapon = WEAPON.NONE,
	weapon_mastery = 0,
	STR_per_level = 0,
	MAG_per_level = 0,
	SPD_per_level = 0,
	max_energy = 1,
	gender = GENDER.NONE
}

return def