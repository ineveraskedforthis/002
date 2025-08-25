---@type MetaActor
local def = {
	MAX_HP = 150,
	DEF = 0,
	SPD = 150,
	name = "Flower",
	inherent_skills = {
		require "skills.wait",
		require "skills.poison-attack",
		require "skills.poison-storm-attack"
	},
	image = love.graphics.newImage("assets/flower.png"),
	image_action_bar = love.graphics.newImage("assets/flower-h.png"),
	image_battle = love.graphics.newImage("assets/flower-square.png"),
	MAG = 5,
	STR = 20,
	alignment = {},
	weapon = WEAPON.DAGGER,
	weapon_mastery = 0,
	STR_per_level = 5,
	MAG_per_level = 1,
	SPD_per_level = 3,
	max_energy = 4,
}

def.alignment[ELEMENT.CHAOS] = true

return def