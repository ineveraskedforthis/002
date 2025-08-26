---@type MetaActor
local def = {
	MAX_HP = 100,
	MAG = 50,
	alignment = {},
	weapon = WEAPON.NONE,
	weapon_mastery = 0,
	STR = 5,
	DEF = 0,
	SPD = 100,
	name = "Kols",
	inherent_skills = {require "skills.wait", require "skills.magic-arrow"},
	image = love.graphics.newImage("assets/kols.png"),
	image_action_bar = love.graphics.newImage("assets/kols-h.png"),
	STR_per_level = 0,
	MAG_per_level = 5,
	SPD_per_level = 0,
	max_energy = 10,
}

def.alignment[ELEMENT.FIRE] = true

return def