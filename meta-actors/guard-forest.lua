---@type MetaActor
local def = {
	MAX_HP = 100,
	DEF = 0,
	SPD = 100,
	name = "Mai Toi",
	inherent_skills = {require "skills.wait", require "skills.attack"},
	image = love.graphics.newImage("assets/actors/forest-guard/big.png"),
	image_battle = love.graphics.newImage("assets/actors/forest-guard/big.png"),
	image_action_bar = love.graphics.newImage("assets/actors/forest-guard/big.png"),
	MAG = 0,
	STR = 20,
	alignment = {},
	weapon = WEAPON.SWORD,
	weapon_mastery = 0,
	STR_per_level = 1,
	MAG_per_level = 1,
	SPD_per_level = 1,
	max_energy = 8,
	gender = GENDER.MALE
}

return def