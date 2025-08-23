---@type MetaActor
local def = {
	MAX_HP = 80,
	MAG = 40,
	alignment = {},
	weapon = WEAPON.NONE,
	weapon_mastery = 0,
	STR = 5,
	DEF = 0,
	SPD = 120,
	name = "Trong",
	inherent_skills = {require "skills.wait", require "skills.energy-link"},
	image = love.graphics.newImage("assets/trong.png"),
	image_battle = love.graphics.newImage("assets/trong-square.png"),
	image_action_bar = love.graphics.newImage("assets/trong-h.png"),
	STR_per_level = 1,
	MAG_per_level = 8,
	SPD_per_level = 1,
	max_energy = 12,
}

def.alignment[ELEMENT.ELECTRO] = true

return def