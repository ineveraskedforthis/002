---@type MetaActor
local def = {
	MAX_HP = 60,
	MAG = 25,
	alignment = {},
	weapon = WEAPON.SWORD,
	weapon_mastery = 0,
	STR = 15,
	DEF = 0,
	SPD = 120,
	name = "Rebe",
	inherent_skills = {require "skills.wait", require "skills.attack", require "skills.flicker-strike"},
	image = love.graphics.newImage("assets/rebe.png"),
	image_action_bar = love.graphics.newImage("assets/rebe-h.png"),
	STR_per_level = 2,
	MAG_per_level = 4,
	SPD_per_level = 5,
}

def.alignment[ELEMENT.LIGHT] = true

return def