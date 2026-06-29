---@type MetaActor
local def = {
	MAX_HP = 100,
	DEF = 0,
	SPD = 100,
	name = "Font",
	inherent_skills = {
		require "skills.wait",
		require "skills.attack",
		require "skills.mountain-breaker",
		require "skills.counter-attack"
	},
	image = love.graphics.newImage("assets/font.png"),
	image_action_bar = love.graphics.newImage("assets/font-h.png"),
	image_battle = love.graphics.newImage("assets/font-square.png"),
	MAG = 0,
	STR = 15,
	alignment = {},
	weapon = WEAPON.SWORD,
	weapon_mastery = 1,
	STR_per_level = 2,
	MAG_per_level = 0,
	SPD_per_level = 1,
	max_energy = 10,
	gender = GENDER.FEMALE
}

return def