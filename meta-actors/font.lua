---@type MetaActor
local def = {
	MAX_HP = 200,
	DEF = 0,
	SPD = 100,
	name = "Font",
	inherent_skills = {
		require "skills.wait",
		require "skills.attack",
	},
	image = love.graphics.newImage("assets/font.png"),
	image_action_bar = love.graphics.newImage("assets/font-h.png"),
	image_battle = love.graphics.newImage("assets/font-square.png"),
	MAG = 0,
	STR = 30,
	alignment = {},
	weapon = WEAPON.SWORD,
	weapon_mastery = 1,
	STR_per_level = 7,
	MAG_per_level = 1,
	SPD_per_level = 1,
	max_energy = 6,
}

return def