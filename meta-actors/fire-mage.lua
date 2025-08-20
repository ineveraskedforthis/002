---@type MetaActor
local def = {
	MAX_HP = 60,
	MAG = 50,
	alignment = {},
	weapon = WEAPON.NONE,
	weapon_mastery = 0,
	STR = 10,
	DEF = 0,
	SPD = 100,
	name = "Kols",
	inherent_skills = {require "skills.wait"},
	image = love.graphics.newImage("assets/kols.png"),
	image_action_bar = love.graphics.newImage("assets/kols-h.png"),
	STR_per_level = 1,
	MAG_per_level = 8,
	SPD_per_level = 1,
}

def.alignment[ELEMENT.FIRE] = true

return def